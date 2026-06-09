import { Injectable, OnModuleInit } from '@nestjs/common';
import {
  Counter,
  Histogram,
  Registry,
  collectDefaultMetrics,
} from 'prom-client';

@Injectable()
export class MetricsService implements OnModuleInit {
  private readonly registry: Registry;

  readonly httpRequestsTotal: Counter<string>;
  readonly httpRequestDurationSeconds: Histogram<string>;

  constructor() {
    this.registry = new Registry();

    // Etiqueta global de la aplicación
    this.registry.setDefaultLabels({ app: 'lymon-backend' });

    // Métricas del proceso (CPU, memoria, event loop, etc.)
    collectDefaultMetrics({ register: this.registry });

    // Counter: total de peticiones HTTP por método, ruta y status code
    this.httpRequestsTotal = new Counter({
      name: 'http_requests_total',
      help: 'Total de peticiones HTTP recibidas',
      labelNames: ['method', 'route', 'status_code'],
      registers: [this.registry],
    });

    // Histogram: latencia de las peticiones HTTP en segundos
    this.httpRequestDurationSeconds = new Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duración de las peticiones HTTP en segundos',
      labelNames: ['method', 'route', 'status_code'],
      buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
      registers: [this.registry],
    });
  }

  onModuleInit() {
    // El registry ya se inicializa en el constructor
  }

  async getMetrics(): Promise<string> {
    return this.registry.metrics();
  }

  getContentType(): string {
    return this.registry.contentType;
  }
}
