use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::time::Duration;

const ADDR: &str = "0.0.0.0:8080";

fn main() {
    // A scratch image has no wget or curl, so the binary doubles as its own HEALTHCHECK probe.
    if std::env::args().nth(1).as_deref() == Some("healthcheck") {
        std::process::exit(if probe() { 0 } else { 1 });
    }

    let listener = TcpListener::bind(ADDR).expect("bind 0.0.0.0:8080");
    for stream in listener.incoming().flatten() {
        let _ = handle(stream);
    }
}

fn handle(mut stream: TcpStream) -> std::io::Result<()> {
    stream.set_read_timeout(Some(Duration::from_secs(5)))?;
    let mut buf = [0u8; 1024];
    let n = stream.read(&mut buf)?;
    let request = String::from_utf8_lossy(&buf[..n]);
    let body = if request.starts_with("GET /health ") {
        "{\"status\":\"ok\"}\n"
    } else {
        "Hello from Rust\n"
    };
    write!(
        stream,
        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
        body.len(),
        body
    )
}

fn probe() -> bool {
    let Ok(mut stream) = TcpStream::connect("127.0.0.1:8080") else {
        return false;
    };
    let _ = stream.set_read_timeout(Some(Duration::from_secs(2)));
    if stream.write_all(b"GET /health HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n").is_err() {
        return false;
    }
    let mut response = String::new();
    stream.read_to_string(&mut response).is_ok() && response.starts_with("HTTP/1.1 200")
}
