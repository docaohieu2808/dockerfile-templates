import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Lets SIGTERM from `docker stop` close the app cleanly.
  app.enableShutdownHooks();
  await app.listen(process.env.PORT ?? 3000, "0.0.0.0");
}

bootstrap();
