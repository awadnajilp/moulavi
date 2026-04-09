const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seedParties() {
  try {
    console.log('🌱 Seeding sample parties...');
    
    // Get admin user
    const admin = await prisma.user.findFirst({ where: { email: 'admin@moulavi.com' } });
    if (!admin) {
      console.error('❌ Admin user not found. Please run create-admin first.');
      return;
    }

    // Get currency
    const sar = await prisma.currencyMaster.findFirst({ where: { currencyCode: 'SAR' } });
    if (!sar) {
      console.error('❌ SAR currency not found. Please run seed-master first.');
      return;
    }

    // Create a few sample parties
    const parties = [
      {
        partyName: 'Al-Haram Travel Agency',
        partyCode: 'HTA001',
        email: 'agency@alharam.com',
        customerType: 'b2b',
        isCustomer: true,
        address: 'Makkah, Saudi Arabia',
        contactNumber: '966500000001',
        createdBy: admin.id,
        accountCurrencyId: sar.id,
      },
      {
        partyName: 'Elite Umrah Services',
        partyCode: 'EUS002',
        email: 'info@eliteumrah.com',
        customerType: 'b2b',
        isCustomer: true,
        address: 'Dubai, UAE',
        contactNumber: '971500000002',
        createdBy: admin.id,
        accountCurrencyId: sar.id,
      }
    ];

    for (const party of parties) {
      const existing = await prisma.party.findUnique({ where: { email: party.email } });
      if (!existing) {
        await prisma.party.create({ data: party });
        console.log(`✅ Created party: ${party.partyName}`);
      } else {
        console.log(`⏭️  Party already exists: ${party.partyName}`);
      }
    }

    console.log('✅ Party seeding completed!');
  } catch (error) {
    console.error('❌ Error seeding parties:', error);
  } finally {
    await prisma.$disconnect();
  }
}

seedParties();
