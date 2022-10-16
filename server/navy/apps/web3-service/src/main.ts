import { Web3ServiceGrpcClientOptions } from '@app/shared-library/gprc/grpc.web3.service';
import { NestFactory } from '@nestjs/core';
import { MicroserviceOptions } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(AppModule, Web3ServiceGrpcClientOptions);
  await app.listen();
}
bootstrap();