// Seed completo: tenant + property + 2 units
// ObjectId is available natively in mongosh shell

const tenantId = new ObjectId();
const propertyId = new ObjectId();

// 1. Tenant (Hotel Manager)
db.tenants.insertOne({
  _id: tenantId,
  name: "Hotel Lymon Demo",
  ownerEmail: "admin@lymon.demo",
  plan: "PREMIUM",
  emailVerified: true,
  contactPhone: "+57 300 123 4567",
  address: "Calle 123 #45-67, Bogotá",
  website: "https://lymon.demo",
  logoUrl: null,
  deletedAt: null,
  createdAt: new Date(),
  updatedAt: new Date()
});
print("✅ Tenant creado: " + tenantId);

// 2. Property
db.properties.insertOne({
  _id: propertyId,
  tenantId: tenantId,
  name: "Hotel Lymon Bogotá",
  description: "Un hermoso hotel boutique en el corazón de Bogotá, con vistas espectaculares a los cerros orientales.",
  propertyType: "HOTEL",
  address: "Carrera 7 #32-16",
  city: "Bogotá",
  state: "Cundinamarca",
  country: "Colombia",
  zipCode: "110311",
  location: { lat: 4.6097, lng: -74.0817 },
  checkInTime: "15:00",
  checkOutTime: "12:00",
  cancellationPolicy: "FLEXIBLE",
  hostPhone: "+57 300 123 4567",
  hostEmail: "admin@lymon.demo",
  deletedAt: null,
  createdAt: new Date(),
  updatedAt: new Date()
});
print("✅ Property creada: " + propertyId);

// 3. Unit 1 - Suite Deluxe
const unitId1 = new ObjectId();
db.units.insertOne({
  _id: unitId1,
  tenantId: tenantId,
  propertyId: propertyId,
  name: "Suite Deluxe",
  description: "Amplia suite con cama king size, jacuzzi privado y vista panorámica a los cerros de Bogotá. Perfecta para parejas.",
  inventoryCount: 2,
  maxGuests: 2,
  standardGuests: 2,
  bedrooms: [
    {
      roomName: "Habitación principal",
      beds: [{ type: "KING", count: 1 }]
    }
  ],
  bathroomsCount: 1,
  isShared: false,
  amenities: ["WiFi gratuito", "TV 55\"", "Minibar", "Jacuzzi", "Aire acondicionado", "Caja fuerte", "Room service 24h"],
  pricePerNight: 350000,
  externalIds: {},
  deletedAt: null,
  createdAt: new Date(),
  updatedAt: new Date()
});
print("✅ Unit 1 creada (Suite Deluxe): " + unitId1);

// 4. Unit 2 - Habitación Estándar
const unitId2 = new ObjectId();
db.units.insertOne({
  _id: unitId2,
  tenantId: tenantId,
  propertyId: propertyId,
  name: "Habitación Estándar",
  description: "Cómoda habitación con cama doble, decoración moderna y todas las comodidades para una estadía perfecta.",
  inventoryCount: 5,
  maxGuests: 2,
  standardGuests: 1,
  bedrooms: [
    {
      roomName: "Habitación principal",
      beds: [{ type: "DOUBLE", count: 1 }]
    }
  ],
  bathroomsCount: 1,
  isShared: false,
  amenities: ["WiFi gratuito", "TV 43\"", "Aire acondicionado", "Escritorio", "Closet amplio"],
  pricePerNight: 180000,
  externalIds: {},
  deletedAt: null,
  createdAt: new Date(),
  updatedAt: new Date()
});
print("✅ Unit 2 creada (Habitación Estándar): " + unitId2);

print("\n🎉 Base de datos sembrada exitosamente!");
print("Tenant ID: " + tenantId);
print("Property ID: " + propertyId);
