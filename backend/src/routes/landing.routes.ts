import { Router, Request, Response } from 'express';
import { 
  sendLandingRegistrationThankYouEmail, 
  sendLandingRegistrationAdminNotificationEmail 
} from '../services/emailService';
import { prisma } from '../lib/prisma';

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

    // 1. Save to database
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

    console.log('[LANDING] Saved to database with ID:', landingReg.id);

    // 2. Send Thank You email to customer
    if (email) {
      await sendLandingRegistrationThankYouEmail(email, contact_name || party_name);
    }

    // 3. Send Notification email to admin
    await sendLandingRegistrationAdminNotificationEmail(registrationDetails);

    res.status(200).json({
      success: true,
      message: 'Registration request received and saved successfully',
      data: { id: landingReg.id }
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
