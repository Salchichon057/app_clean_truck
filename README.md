# ComasLimpio 🚛♻️

**Sistema de Notificaciones de Recolección de Basura en Tiempo Real**

ComasLimpio es una aplicación móvil desarrollada en Flutter que permite a los ciudadanos recibir notificaciones en tiempo real cuando el camión de basura está cerca de su ubicación, optimizando así el proceso de recolección de residuos en el distrito de Comas, Lima.

## 📱 Funcionalidades Principales

### 👥 Para Ciudadanos
- **Selección de Rutas**: Los ciudadanos pueden seleccionar la ruta de recolección de su zona
- **Notificaciones en Tiempo Real**: Reciben alertas automáticas cuando el camión está a menos de 200 metros
- **Visualización de Rutas**: Pueden ver en el mapa las rutas de recolección disponibles
- **Historial de Notificaciones**: Acceso a todas las notificaciones recibidas

### 🚛 Para Conductores de Camión
- **Selección de Camión**: Los conductores pueden seleccionar el camión asignado
- **Tracking GPS**: Envío automático de ubicación cada 30 segundos
- **Visualización de Ruta**: Pueden ver su ruta asignada en el mapa
- **Control de Servicio**: Activar/desactivar el envío de ubicación
- **Debug Interface**: Herramientas para monitorear el estado de las notificaciones

### 👔 Para Administradores
- **Gestión de Camiones**: Crear, editar y eliminar camiones de la flota
- **Gestión de Conductores**: Crear cuentas para conductores y asignar camiones
- **Creación de Rutas**: Definir rutas de recolección en el mapa con múltiples puntos
- **Monitoreo en Tiempo Real**: Ver ubicación de todos los camiones activos

## 🏗️ Arquitectura del Sistema

### Roles de Usuario
```
📊 Admin
├── Gestiona camiones y conductores
├── Crea y administra rutas
└── Monitorea operaciones en tiempo real

🚛 Conductor (truck_driver)
├── Selecciona camión asignado
├── Inicia/detiene ruta
└── Envía ubicación automáticamente

👤 Ciudadano (citizen)
├── Selecciona ruta de su zona
├── Recibe notificaciones automáticas
└── Ve historial de alertas
```

## 🔄 Flujo de Funcionamiento

### 1. Configuración Inicial (Admin)
1. **Registro de Camiones**: Admin registra camiones con datos (marca, modelo, placa, año)
2. **Creación de Conductores**: Admin crea cuentas para conductores
3. **Definición de Rutas**: Admin crea rutas seleccionando puntos en el mapa
4. **Asignación**: Se asigna camión específico a cada ruta

### 2. Proceso de Recolección (Conductor)
1. **Login**: Conductor inicia sesión en la app
2. **Selección de Camión**: Elige el camión que va a manejar
3. **Activación de Ruta**: La ruta se activa automáticamente al seleccionar camión
4. **Inicio de Tracking**: 
   - Activa el toggle "Enviar ubicación"
   - La app envía ubicación GPS cada 30 segundos
   - Los datos se envían tanto a Firestore como a la API TypeScript

### 3. Suscripción de Ciudadanos
1. **Selección de Ruta**: Ciudadano abre la app y selecciona su ruta
2. **Registro de Ubicación**: La app solicita permisos de ubicación
3. **Activación de FCM**: Se registra el token FCM para notificaciones push
4. **Suscripción Activa**: Queda suscrito a notificaciones de esa ruta específica

### 4. Sistema de Notificaciones Controladas

#### ❌ Firebase Functions (Sistema Legacy - Reemplazado)
```javascript
// ANTES: Trigger automático (eliminado para mayor control)
onDocumentWritten("app_users/{userId}") // ← Automático, sin control
├── Se ejecutaba en cada cambio de documento
├── Dificultad para debuggear
├── Sin control de timing
└── Menos eficiente
```

#### ✅ TypeScript API (Sistema Principal)
```typescript
// AHORA: Control total desde Flutter
POST /api/update-truck-location
├── 🎯 Llamada controlada desde Flutter cada 30 segundos
├── 📊 Logging detallado de cada operación
├── ⚡ Respuesta inmediata con estadísticas
├── 🔧 Fácil debugging y monitoreo
├── 🚀 Mejor performance y control de errores
└── 📈 Métricas precisas de notificaciones enviadas

Flujo controlado:
1. Conductor activa "Enviar ubicación" en Flutter
2. Timer envía ubicación cada 30s a API TypeScript
3. API procesa y envía notificaciones inmediatamente
4. Flutter recibe confirmación y estadísticas
5. UI se actualiza con estado en tiempo real
```

## 🛠️ Configuración y Tecnologías

### Frontend (Flutter)
```yaml
dependencies:
  flutter_riverpod: ^2.4.9     # Estado global
  go_router: ^12.1.3           # Navegación
  flutter_map: ^6.1.0          # Mapas
  geolocator: ^10.1.0          # GPS
  firebase_core: ^2.24.2       # Firebase
  firebase_auth: ^4.15.3       # Autenticación
  cloud_firestore: ^4.13.6     # Base de datos
  firebase_messaging: ^14.7.10 # Notificaciones push
  http: ^1.1.2                 # Llamadas HTTP
```

### Backend
```
Firebase Services:
├── 🔐 Authentication (manejo de usuarios)
├── 📊 Firestore (base de datos NoSQL)
├── 📱 FCM (notificaciones push)
└── ☁️ Functions (lógica serverless)

TypeScript API:
├── 🚀 Express.js server
├── 📊 Firebase Admin SDK
├── 🔔 FCM notifications
└── 📍 Geolocation calculations
```

## 📂 Estructura del Código

```
lib/
├── core/
│   ├── services/
│   │   ├── fcm_service.dart           # Configuración FCM
│   │   └── notification_api_service.dart # Cliente HTTP API
│   ├── presentation/
│   │   ├── router/app_router.dart     # Rutas de navegación
│   │   ├── theme/app_theme.dart       # Tema de la app
│   │   └── widgets/
│   │       ├── notifications_screen.dart # Pantalla notificaciones
│   │       └── *_navigation_bar.dart     # Barras de navegación
│   └── config/map_token.dart          # Token de Mapbox
├── features/
│   ├── auth/                          # Autenticación
│   ├── admin/                         # Funciones de administrador
│   ├── citizen/                       # Funciones de ciudadano
│   └── truck_drive/                   # Funciones de conductor
│       ├── presentation/
│       │   ├── providers/
│       │   │   ├── notification_api_provider.dart # Estado API
│       │   │   └── active_truck_route_provider.dart
│       │   └── views/
│       │       ├── truck_selection_screen.dart    # Selección camión
│       │       └── truck_view_route_screen.dart   # Pantalla principal conductor
```

## 🚀 Comandos de Desarrollo

### Prerequisitos
```bash
# Flutter SDK
# Firebase CLI
# Node.js (para TypeScript API)
```

### Configuración Inicial
```bash
# 1. Clonar repositorio
git clone <repository-url>
cd comaslimpio

# 2. Instalar dependencias Flutter
flutter pub get

# 3. Configurar API TypeScript
cd notification-api
npm install

# 4. Configurar variables de entorno
# Crear .env con:
NOTIFICATION_API_URL=http://localhost:3000
```

### Ejecutar en Desarrollo
```bash
# Terminal 1: API TypeScript
cd notification-api
npm run dev

# Terminal 2: Flutter App
flutter run
```

### Testing
```bash
# Análisis de código
flutter analyze

# Tests unitarios
flutter test

# Verificar API
curl http://localhost:3000/health
```

## 📊 Base de Datos (Firestore)

### Colecciones Principales

#### `app_users`
```javascript
{
  uid: string,
  name: string,
  email: string,
  role: "admin" | "truck_driver" | "citizen",
  status: "active" | "inactive",
  location: { lat: number, long: number },
  fcmToken: string,
  selectedRouteId: string, // Solo ciudadanos
  created_at: timestamp
}
```

#### `trucks`
```javascript
{
  idTruck: string,        // Placa del camión
  brand: string,
  model: string,
  yearOfManufacture: number,
  status: "available" | "unavailable",
  id_app_user: string     // UID del conductor asignado
}
```

#### `routes`
```javascript
{
  uid: string,
  routeName: string,
  points: [
    { lat: number, long: number }
  ],
  id_truck: string,       // Placa del camión asignado
  status: "active" | "inactive",
  created_at: timestamp
}
```

#### `notifications` (subcollection of app_users)
```javascript
{
  uid: string,
  type: "truck_near",
  routeId: string,
  message: string,
  timestamp: timestamp,
  read: boolean
}
```

## 🔔 Sistema de Notificaciones Detallado

### Condiciones para Envío
1. **Distancia**: Camión debe estar ≤ 200 metros del ciudadano
2. **Suscripción**: Ciudadano debe estar suscrito a la ruta activa
3. **Throttling**: No enviar si ya se notificó en los últimos 3 minutos
4. **FCM Token**: Ciudadano debe tener token válido
5. **Ubicación**: Tanto camión como ciudadano deben tener ubicación

### Tipos de Notificación
- **truck_near**: Camión cerca (≤ 200m)
- **test_notification**: Notificación de prueba (solo debug)

### Cálculo de Distancia
Utiliza la **fórmula Haversine** para calcular distancia entre dos puntos geográficos:
```javascript
function getDistanceFromLatLonInMeters(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radio de la Tierra en km
  const dLat = deg2rad(lat2-lat1);
  const dLon = deg2rad(lon2-lon1);
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c * 1000; // Convertir a metros
}
```

## 🧪 Guía de Testing

### Escenarios de Prueba

#### 1. Flujo Completo de Notificación
```bash
# Terminal 1: API
cd notification-api && npm run dev

# Terminal 2: App
flutter run

# Pasos en la app:
1. Login como conductor
2. Seleccionar camión
3. Activar "Enviar ubicación"
4. En otro dispositivo: login como ciudadano
5. Seleccionar la misma ruta
6. Simular movimiento del conductor cerca del ciudadano
7. Verificar notificación recibida
```

#### 2. Testing de API
```bash
# Health check
curl http://localhost:3000/health

# Test manual de notificación
curl -X POST http://localhost:3000/api/update-truck-location \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "conductor-uid",
    "location": {"lat": -11.9498, "long": -77.0622}
  }'
```

## 🔧 Troubleshooting

### Problemas Comunes

#### Notificaciones no llegan
1. Verificar permisos de ubicación
2. Confirmar FCM token registrado
3. Revisar que el ciudadano esté suscrito a la ruta correcta
4. Verificar que el throttling no esté bloqueando

#### API TypeScript no conecta
1. Verificar que esté ejecutándose en puerto 3000
2. Revisar variable NOTIFICATION_API_URL en .env
3. Confirmar credenciales Firebase en service-account-key.json

#### Flutter analyze warnings
- Los warnings de `print` son normales en desarrollo
- No usar `print` en producción (usar logger apropiado)

## 🌟 Próximas Mejoras

### Funcionalidades Planificadas
- [ ] Notificaciones programadas por horarios
- [ ] Histórico de rutas completadas
- [ ] Dashboard de métricas para admin
- [ ] Modo offline básico
- [ ] Optimización de batería

### Mejoras Técnicas
- [ ] Migración completa a TypeScript API
- [ ] Implementar push notifications avanzadas
- [ ] Cache de datos offline
- [ ] Tests unitarios completos
- [ ] CI/CD pipeline

## 📞 Soporte

Para reportar bugs o solicitar nuevas funcionalidades, crear un issue en el repositorio.

---
*Desarrollado para optimizar la recolección de basura en Comas, Lima 🇵🇪*
