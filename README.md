Paquexpress Logística (Modern UI) 🚚✨

Versión refactorizada de la aplicación móvil para la gestión de entregas de última milla de Paquexpress S.A. de C.V.

Esta edición presenta una Interfaz de Usuario (UI) totalmente renovada, enfocada en la ergonomía y la claridad visual, utilizando una paleta de colores moderna (Teal/Naranja) y componentes estilizados, manteniendo la robustez del backend en Python.

🎨 Novedades de esta Versión

Identidad Visual: Nuevo esquema de colores "Teal & Orange" con degradados modernos.

Experiencia de Usuario (UX): Tarjetas de entrega rediseñadas con indicadores de estado visuales.

Mapa Inmersivo: Pantalla de entrega con mapa a pantalla completa y paneles deslizantes traslúcidos.

Feedback Visual: Nuevos íconos y animaciones de carga mejoradas.

🚀 Stack Tecnológico

Frontend: Flutter (Dart) con Material 3 modificado.

Mapas: Flutter Map (OpenStreetMap) con marcadores personalizados.

Backend: FastAPI (Python) + Uvicorn.

Base de Datos: MySQL con SQLAlchemy.

Seguridad: Hashing Bcrypt para credenciales.

🛠️ Guía de Instalación y Despliegue

Sigue estos pasos para levantar el entorno completo (Base de datos, Servidor y App).

1. Base de Datos (MySQL)

El sistema requiere una base de datos relacional para operar.

Inicia tu servicio de MySQL (XAMPP, WAMP o Workbench).

Ejecuta el script database_script.sql incluido en este repositorio para generar las tablas users y packages.

Verificación: Asegúrate de que la conexión en el archivo main.py de la API coincida con tus credenciales locales:

SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:root@localhost/paquexpress_db"


2. Backend (API REST)

El servidor maneja la lógica de negocio y la recepción de evidencias.

Entorno Virtual: Navega a la carpeta de la API y crea/activa el entorno aislado:

# Crear (si no existe)
python -m venv env

# Activar (Windows)
.\env\Scripts\activate


Dependencias: Instala las librerías necesarias:

pip install fastapi uvicorn sqlalchemy pymysql cryptography python-multipart aiofiles passlib[bcrypt] pydantic


Ejecución: Levanta el servidor:

python main.py


La API escuchará peticiones en http://localhost:8000.

3. Aplicación Móvil (Flutter)

Dependencias: Descarga los paquetes de Flutter (incluyendo los nuevos assets visuales):

flutter pub get


Ejecución: Lanza la aplicación en tu emulador o navegador:

flutter run


📱 Manual de Uso

1. Inicio de Sesión (Nueva Pantalla)

Acceso: Al abrir la app, verás el nuevo login con fondo degradado.

Credenciales: Ingresa tu usuario (ej. agente1) y contraseña.

Nota: Si es la primera vez, crea el usuario vía Postman enviando un POST a http://localhost:8000/admin/create_user/.

2. Tablero de Asignaciones

Visualizarás tus entregas pendientes en tarjetas estilizadas con una barra lateral naranja.

Toca cualquier tarjeta para abrir el detalle de la entrega.

3. Confirmación de Entrega (Mapa Inmersivo)

Ubicación: El mapa ahora ocupa toda la pantalla. Un marcador tipo "gota de agua" azul indica tu posición GPS.

Evidencia: Desliza o interactúa con el panel inferior blanco.

Toca el recuadro de la cámara para capturar la foto.

Presiona el botón negro "CONFIRMAR ENTREGA".

Si el envío es exitoso, recibirás una notificación visual y regresarás a la lista.

⚠️ Configuración de Red

Para asegurar la conexión entre el dispositivo y el servidor local:

Emulador Android: La app usa 10.0.2.2 para conectar con tu PC.

Navegador Web: La app usa 127.0.0.1. Importante: El servidor backend debe tener configurado CORS permitiendo el acceso (verificado en main.py).

Dispositivo Físico: Debes editar la variable _baseUrl en los archivos .dart con la IP LAN de tu computadora (ej. 192.168.1.50).

Materia: Desarrollo de Aplicaciones Móviles
Proyecto: Evidencia de Aprendizaje Unidad 3