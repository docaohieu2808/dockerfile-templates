import { Controller, Get } from "@nestjs/common";

@Controller()
export class AppController {
  @Get()
  hello(): string {
    return "Hello from NestJS";
  }

  @Get("health")
  health(): { status: string } {
    return { status: "ok" };
  }
}
