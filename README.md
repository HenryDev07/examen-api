# Personajes de Los Simpson

Aplicación Flutter que consulta personajes desde la API pública de Los Simpson. Permite buscar en la página cargada, ver detalles y guardar favoritos localmente.

## Acceso de demostración

- Usuario: `RaulCooking`
- Contraseña: `Prueba12345`

El acceso es fijo para la demostración y no reemplaza una autenticación segura.

## Funcionalidades

- Catálogo paginado obtenido por HTTP desde `https://thesimpsonsapi.com/api/characters`.
- Búsqueda local por nombre en la página actual.
- Vista de detalle con información e imagen del personaje.
- Favoritos persistidos localmente con SharedPreferences.
- Estados de carga, errores con opción de reintento y sustituto visual para imágenes que no cargan.

## Ejecutar y probar

```sh
flutter pub get
flutter run
flutter test
```

Se requiere conexión a internet para cargar el catálogo y los detalles.

## Integrantes y contribuciones

Completar con los nombres de los integrantes del equipo y la contribución técnica de cada uno antes de entregar el proyecto.
