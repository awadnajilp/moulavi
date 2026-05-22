import { Router, Request, Response } from 'express';
import { 
  sendLandingRegistrationThankYouEmail, 
  sendLandingRegistrationAdminNotificationEmail 
} from '../services/emailService';
import { prisma } from '../lib/prisma';
import bcrypt from 'bcrypt';
import crypto from 'crypto';

const router = Router();

/**
 * @route POST /api/landing/register
 * @desc Handle registration from the landing page and save to database
 * @access Public
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const registrationDetails = req.body;
    const { 
      party_name, 
      party_code,
      email, 
      whatsapp_number,
      contact_number,
      address,
      contact_name,
      contact_person_number,
      department,
      gst_number,
      pan_number,
      aadhaar_number,
      account_currency_id,
      customer_type,
      login_required,
      email_notification,
      sms_notification
    } = registrationDetails;

    console.log('[LANDING] New registration received:', party_name);

    // 1. Save to landing_registrations (audit trail)
    const landingReg = await prisma.landingRegistration.create({
      data: {
        partyName: party_name,
        partyCode: party_code || null,
        email: email,
        whatsappNumber: whatsapp_number,
        contactNumber: contact_number || null,
        address: address || null,
        contactName: contact_name || null,
        contactPersonNumber: contact_person_number || null,
        department: department || null,
        gstNumber: gst_number || null,
        panNumber: pan_number || null,
        aadhaarNumber: aadhaar_number || null,
        accountCurrencyId: account_currency_id || 'sar_id',
        customerType: customer_type || 'b2b',
        loginRequired: login_required === true || login_required === 'true',
        emailNotification: email_notification !== false && email_notification !== 'false',
        smsNotification: sms_notification !== false && sms_notification !== 'false',
        status: 'pending'
      }
    });

    let generatedPassword = '';
    
    // 2. Automatically create User and Party if login is required
    if (login_required === true || login_required === 'true') {
      // Check if user already exists
      const existingUser = await prisma.user.findUnique({ where: { email } });
      
      if (!existingUser) {
        // Generate secure random password
        generatedPassword = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 char hex
        const hashedPassword = await bcrypt.hash(generatedPassword, 10);
        
        // Find admin user for 'created_by' (needed by Party model)
        const adminUser = await prisma.user.findFirst({ where: { role: 'admin' } });
        if (!adminUser) throw new Error('System admin not found');

        // Create User
        const newUser = await prisma.user.create({
          data: {
            name: contact_name || party_name,
            email,
            password: hashedPassword,
            role: 'party',
            isActive: true
          }
        });

        // Create Party
        await prisma.party.create({
          data: {
            partyName: party_name,
            partyCode: party_code || `AGN${landingReg.id.substring(0, 5).toUpperCase()}`,
            email,
            contactNumber: contact_number || null,
            whatsappNumber: whatsapp_number,
            address: address || null,
            customerType: customer_type === 'direct' ? 'direct' : 'b2b',
            isCustomer: true,
            isSupplier: false,
            loginRequired: true,
            userId: newUser.id,
            createdBy: adminUser.id,
            accountCurrencyId: account_currency_id || 'sar_id',
            gstNumber: gst_number || null,
            panNumber: pan_number || null,
            aadhaarNumber: aadhaar_number || null
          }
        });
        
        console.log('[LANDING] Created User and Party for:', email);
      }
    }

    // 3. Send Thank You email to customer (with credentials if created)
    if (email) {
      await sendLandingRegistrationThankYouEmail(
        email, 
        contact_name || party_name, 
        generatedPassword || undefined
      );
    }

    // 4. Send Notification email to admin
    await sendLandingRegistrationAdminNotificationEmail(registrationDetails);

    res.status(200).json({
      success: true,
      message: 'Registration request received and account created',
      data: { id: landingReg.id, accountCreated: !!generatedPassword }
    });
  } catch (error: any) {
    console.error('[LANDING] Registration error:', error.message);
    res.status(500).json({
      success: false,
      message: 'An error occurred during registration: ' + error.message
    });
  }
});

export default router;
