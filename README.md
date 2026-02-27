
![License](https://img.shields.io/badge/license-MIT-blue.svg)


## Características de Código Abierto

Este proyecto se distribuye bajo la licencia MIT, lo que significa que puedes usarlo, modificarlo y distribuirlo libremente. Invitamos a la comunidad a contribuir, reportar problemas (issues) y proponer mejoras (pull requests) para seguir evolucionando la plataforma.

## Cómo Correr el Proyecto (Docker)

Este proyecto está contenerizado para un desarrollo fácil y rápido. Solo necesitas Docker y Docker Compose.

### 1. Prerrequisitos
Asegúrate de tener instalados:
- [Docker Engine](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 2. Iniciar la Aplicación
Para levantar todos los servicios (Base de datos, Redis, Rails):

```bash
docker compose -f docker-compose.dev.yml up -d
```

La aplicación estará disponible en: **http://localhost:5000**

### 3. Detener la Aplicación
Para detener los contenedores:

```bash
docker compose -f docker-compose.dev.yml down
```

### 4. Ver Logs en Tiempo Real
Si necesitas ver qué está pasando en el servidor (errores, logs de Rails):

```bash
docker logs -f dashboard_ip_web
```

---

## Comandos Útiles

Como la aplicación corre dentro de Docker, debes ejecutar los comandos de Rails usando `docker exec`.

### Resetear la Base de Datos (Seeds)
Si quieres borrar todo y cargar los datos de prueba iniciales:

```bash
docker exec dashboard_ip_web bin/rails db:reset
```

### Entrar a la Consola de Rails
Para interactuar directamente con la base de datos o probar código:

```bash
docker exec -it dashboard_ip_web bin/rails console
```

### Correr Migraciones Pendientes
Si agregas nuevos cambios a la base de datos:

```bash
docker exec dashboard_ip_web bin/rails db:migrate
```

### Instalar Nuevas Gemas
Si agregas una gema al `Gemfile`, debes reconstruir el contenedor:

```bash
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up -d
```

---

## Contribuir

¡Las contribuciones son bienvenidas! Si deseas aportar al proyecto, por favor:
1. Haz un fork del repositorio.
2. Crea una rama para tu feature o fix (`git checkout -b feature/nueva-mejora`).
3. Haz commit de tus cambios (`git commit -m 'Agrega nueva mejora'`).
4. Sube tus cambios a tu rama (`git push origin feature/nueva-mejora`).
5. Abre un Pull Request.

Asegúrate de ejecutar las pruebas y linter (ej: `rubocop`) antes de enviar tu PR.

## Licencia

Este proyecto está bajo la Licencia MIT - mira el archivo [LICENSE](LICENSE) para más detalles.
