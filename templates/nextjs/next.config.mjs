/** @type {import('next').NextConfig} */
const nextConfig = {
  // Required by the Dockerfile: emits .next/standalone with only the files needed to run.
  output: "standalone",
};

export default nextConfig;
