const { MongoClient } = require('mongodb');
const { v4: uuidv4 } = require('uuid');

async function seed() {
  const uri = 'mongodb://admin:secret123@database:27017/lymon?authSource=admin';
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db('lymon');

    // 1. Activate all existing guest accounts
    const updateResult = await db.collection('guest_accounts').updateMany(
      {},
      { $set: { 'status.value': 'ACTIVE' } }
    );
    console.log(`Activated ${updateResult.modifiedCount} guest accounts`);

    // 2. Insert a dummy tenant if none exists
    const tenants = await db.collection('tenants').find().toArray();
    let tenantId;
    if (tenants.length === 0) {
      tenantId = uuidv4();
      await db.collection('tenants').insertOne({
        _id: tenantId,
        firstName: 'Test',
        lastName: 'Manager',
        email: 'manager@test.com',
        password: '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuinb/TGKX01Hk1cT.4g8uX2t2F5.lC', // password123
        companyName: 'Test Hotel',
        phone: '1234567890',
        planType: 'PREMIUM',
        status: 'ACTIVE',
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      console.log('Created dummy tenant');
    } else {
      tenantId = tenants[0]._id;
      console.log('Using existing tenant');
    }

    // 3. Insert a dummy property
    const propertyId = uuidv4();
    await db.collection('properties').insertOne({
      _id: propertyId,
      tenantId: tenantId,
      name: 'Grand Hotel Lymon',
      address: {
        street: '123 Main St',
        city: 'Bogotá',
        state: 'Cundinamarca',
        country: 'Colombia',
        zipCode: '110111'
      },
      status: 'ACTIVE',
      createdAt: new Date(),
      updatedAt: new Date()
    });
    console.log('Created dummy property');

    // 4. Insert a dummy unit for the property
    const unitId = uuidv4();
    await db.collection('units').insertOne({
      _id: unitId,
      propertyId: propertyId,
      name: 'Deluxe Suite',
      description: 'Una hermosa suite con vista al mar... en Bogotá.',
      capacity: 2,
      pricePerNight: 150000,
      amenities: ['WiFi', 'TV', 'Minibar', 'Jacuzzi'],
      images: [
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=2070&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=2070&auto=format&fit=crop'
      ],
      status: 'AVAILABLE',
      createdAt: new Date(),
      updatedAt: new Date()
    });
    console.log('Created dummy unit');

  } catch (err) {
    console.error(err);
  } finally {
    await client.close();
  }
}

seed();
