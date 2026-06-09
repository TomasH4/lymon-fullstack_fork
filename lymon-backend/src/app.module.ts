import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { PresentationModule } from '@/presentation/presentation.module';
import { ApplicationModule } from '@/application/application.module';
import { AppController } from '@/app.controller';
import { AppService } from '@/app.service';
import { AuthModule } from '@/infrastructure/auth/auth.module';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { JwtAuthGuard } from '@/infrastructure/auth/guards/jwt-auth.guard';
import { HttpLoggingInterceptor } from '@/presentation/common/interceptors/http-logging.interceptor';
import { AuditInfrastructureModule } from '@/infrastructure/audit/audit-infrastructure.module';
import { ScheduleModule } from '@nestjs/schedule';
import { ReservationInfrastructureModule } from '@/infrastructure/reservation/reservation-infrastructure.module';
import { InventoryInfrastructureModule } from '@/infrastructure/inventory/inventory-infrastructure.module';
import { MetricsModule } from '@/infrastructure/metrics/metrics.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    EventEmitterModule.forRoot(),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        uri: configService.get<string>('MONGODB_URI'),
      }),
      inject: [ConfigService],
    }),
    ScheduleModule.forRoot(),
    AuthModule,
    PresentationModule,
    ApplicationModule,
    AuditInfrastructureModule,
    ReservationInfrastructureModule,
    InventoryInfrastructureModule,
    MetricsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: HttpLoggingInterceptor,
    },
  ],
})
export class AppModule {}
