# Guion de Exposición: Gestión de la Configuración - Proyecto Lymon

Este documento es una guía paso a paso sobre **qué decir** y **qué mostrar** en pantalla durante tu sustentación final. Está diseñado para impresionar a los profesores demostrando dominio de Kubernetes (Minikube) y Observabilidad (Grafana/Prometheus).

---

## Preparación (Antes de que empiece la clase)

1. Asegúrate de tener Docker Desktop corriendo con la memoria configurada (WSL2 con 6GB).
2. Inicia Minikube: `minikube start --memory=5120 --cpus=4`
3. Levanta los puertos en terminales separadas:
   - Frontend: `minikube service frontend-service`
   - Backend: `kubectl port-forward svc/backend 3000:3000`
   - Grafana: `kubectl port-forward svc/grafana 3001:3000 -n monitoring`
4. Ten listas en tu navegador:
   - Pestaña 1: La aplicación Lymon (Frontend).
   - Pestaña 2: Grafana (`http://localhost:3001`) logueado en la sección "Explore".
   - Pestaña 3: Minikube Dashboard (ejecuta `minikube dashboard` en una terminal y déjalo abierto).

---

## Acto 1: Introducción y Arquitectura

**🗣️ Qué decir:**
> "Buenos días. Para el proyecto final de Gestión de la Configuración, hemos implementado el despliegue completo de la plataforma hotelera Lymon utilizando contenedores y orquestación. 
> 
> En lugar de usar herramientas simples, decidimos llevarlo a un entorno de producción simulado usando **Kubernetes** a través de **Minikube**. Nuestra arquitectura consta de varios microservicios: un Frontend en Angular, un Backend en NestJS, y una base de datos MongoDB con persistencia de datos."

**🖥️ Qué mostrar:**
- Abre tu editor de código (VS Code) y muestra rápidamente la carpeta `k8s/`.
- Muestra que tienes archivos separados para `frontend.yaml`, `backend.yaml`, `mongo.yaml` y `monitoring.yaml`. Esto demuestra que la infraestructura está definida como código (IaC).

---

## Acto 2: Demostración de la Aplicación en Vivo

**🗣️ Qué decir:**
> "Primero, veamos la aplicación funcionando dentro del clúster. Todo el tráfico está siendo enrutado por los servicios de Kubernetes."

**🖥️ Qué mostrar:**
- Ve a la pestaña de tu navegador donde está **Lymon**.
- Inicia sesión con la cuenta de prueba (`usuarioprueba1@gmail.com`).
- Navega por las propiedades, haz clic en algunas habitaciones. *(Hacer esto es clave porque generará tráfico HTTP que luego mostraremos en Grafana).*

---

## Acto 3: "Debajo del capó" (Kubernetes)

**🗣️ Qué decir:**
> "Para gestionar todo este entorno, Kubernetes se encarga de mantener nuestras aplicaciones vivas. Si un contenedor falla, Kubernetes lo reinicia automáticamente. Veamos cómo está estructurado."

**🖥️ Qué mostrar:**
1. Abre la pestaña del **Minikube Dashboard**.
2. Navega a la sección **Deployments** y muestra cómo están en verde el backend, frontend y la base de datos.
3. Abre tu **Terminal** y ejecuta en vivo frente a ellos:
   ```powershell
   kubectl get pods
   ```
   *Explica:* "Aquí podemos ver los pods individuales corriendo."
   ```powershell
   kubectl get pvc
   ```
   *Explica:* "Y aquí demostramos que la base de datos tiene un *Persistent Volume Claim*. Esto significa que aunque el contenedor de la base de datos sea destruido, los datos de los hoteles y usuarios no se pierden."

---

## Acto 4: El "Wow Factor" (Monitoreo con Grafana y Prometheus)

**🗣️ Qué decir:**
> "Una parte fundamental de la Gestión de la Configuración es la **Observabilidad**. No basta con desplegar el código, necesitamos saber qué está pasando dentro del clúster en tiempo real.
>
> Para esto, implementamos un stack de monitoreo con **Prometheus** y **Grafana** en un namespace dedicado. Además, configuramos nuestro backend para que exponga métricas reales de la aplicación usando librerías de cliente de Prometheus."

**🖥️ Qué mostrar:**
- Ve a la pestaña de **Grafana** (`http://localhost:3001`).
- Ve a la sección **Explore** (el ícono de la brújula en el menú izquierdo).
- Asegúrate de que **Prometheus** esté seleccionado en el menú desplegable superior izquierdo.

**Métrica 1: Demostrar que están capturando las peticiones de la app**
- En la caja de query escribe: `http_requests_total` y dale al botón azul **Run query**.
- **🗣️ Qué decir:** "Como pueden ver, Prometheus está scrapeando el endpoint de métricas de nuestro backend. Aquí vemos contabilizadas las peticiones exactas que acabo de hacer en la demostración del frontend, desglosadas por ruta, método y código de estado HTTP."

**Métrica 2: Tasa de peticiones por segundo (Gráfico)**
- Cambia la query a: `rate(http_requests_total[5m])` y presiona **Run query**.
- **🗣️ Qué decir:** "Esta consulta nos permite ver gráficamente los picos de tráfico en los últimos 5 minutos. Si tuviéramos un ataque o un pico de usuarios, lo veríamos reflejado aquí inmediatamente."

**Métrica 3: Consumo de recursos**
- Cambia la query a: `process_cpu_seconds_total` y presiona **Run query**.
- **🗣️ Qué decir:** "Y por supuesto, también monitoreamos el consumo de recursos de los contenedores de NodeJS, lo que nos permite tomar decisiones sobre cuándo escalar horizontalmente agregando más réplicas en Kubernetes."

---

## Conclusión

**🗣️ Qué decir:**
> "En conclusión, logramos no solo contenerizar la aplicación, sino establecer un flujo donde la infraestructura es escalable, los datos son persistentes, y tenemos visibilidad total del rendimiento de la aplicación en tiempo real. 
> 
> Muchas gracias."
