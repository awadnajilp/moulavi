/*
  Warnings:

  - You are about to alter the column `new_values` on the `audit_logs` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.
  - You are about to alter the column `old_values` on the `audit_logs` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.
  - You are about to alter the column `supplier_service_types` on the `parties` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.
  - You are about to alter the column `brn` on the `umrah_hotel_bookings` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.
  - You are about to alter the column `multiple_group_details` on the `umrah_visa_bookings` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.
  - You are about to alter the column `permissions` on the `user_role_masters` table. The data in that column could be lost. The data in that column will be cast from `String` to `Json`.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_audit_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "entity_type" TEXT NOT NULL,
    "entity_id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "old_values" JSONB,
    "new_values" JSONB,
    "changed_by" TEXT NOT NULL,
    "changed_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ip_address" TEXT,
    "user_agent" TEXT,
    CONSTRAINT "audit_logs_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_audit_logs" ("action", "changed_at", "changed_by", "entity_id", "entity_type", "id", "ip_address", "new_values", "old_values", "user_agent") SELECT "action", "changed_at", "changed_by", "entity_id", "entity_type", "id", "ip_address", "new_values", "old_values", "user_agent" FROM "audit_logs";
DROP TABLE "audit_logs";
ALTER TABLE "new_audit_logs" RENAME TO "audit_logs";
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs"("entity_type", "entity_id");
CREATE INDEX "audit_logs_changed_by_idx" ON "audit_logs"("changed_by");
CREATE INDEX "audit_logs_changed_at_idx" ON "audit_logs"("changed_at");
CREATE TABLE "new_parties" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "party_code" TEXT,
    "party_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "contact_number" TEXT,
    "whatsapp_number" TEXT,
    "address" TEXT,
    "gst_number" TEXT,
    "customer_type" TEXT NOT NULL,
    "is_supplier" BOOLEAN NOT NULL DEFAULT false,
    "is_customer" BOOLEAN NOT NULL DEFAULT true,
    "login_required" BOOLEAN NOT NULL DEFAULT false,
    "user_id" TEXT,
    "created_by" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email_notification" BOOLEAN NOT NULL DEFAULT true,
    "marketing_notification" BOOLEAN NOT NULL DEFAULT false,
    "sms_notification" BOOLEAN NOT NULL DEFAULT true,
    "account_currency_id" TEXT NOT NULL,
    "pan_number" TEXT,
    "aadhaar_number" TEXT,
    "supplier_service_types" JSONB,
    CONSTRAINT "parties_account_currency_id_fkey" FOREIGN KEY ("account_currency_id") REFERENCES "currency_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "parties_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "parties_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_parties" ("aadhaar_number", "account_currency_id", "address", "contact_number", "created_at", "created_by", "customer_type", "email", "email_notification", "gst_number", "id", "is_customer", "is_supplier", "login_required", "marketing_notification", "pan_number", "party_code", "party_name", "sms_notification", "supplier_service_types", "updated_at", "user_id", "whatsapp_number") SELECT "aadhaar_number", "account_currency_id", "address", "contact_number", "created_at", "created_by", "customer_type", "email", "email_notification", "gst_number", "id", "is_customer", "is_supplier", "login_required", "marketing_notification", "pan_number", "party_code", "party_name", "sms_notification", "supplier_service_types", "updated_at", "user_id", "whatsapp_number" FROM "parties";
DROP TABLE "parties";
ALTER TABLE "new_parties" RENAME TO "parties";
CREATE UNIQUE INDEX "parties_party_code_key" ON "parties"("party_code");
CREATE UNIQUE INDEX "parties_email_key" ON "parties"("email");
CREATE UNIQUE INDEX "parties_user_id_key" ON "parties"("user_id");
CREATE INDEX "parties_email_idx" ON "parties"("email");
CREATE INDEX "parties_party_name_idx" ON "parties"("party_name");
CREATE INDEX "parties_party_code_idx" ON "parties"("party_code");
CREATE INDEX "parties_customer_type_idx" ON "parties"("customer_type");
CREATE INDEX "parties_user_id_idx" ON "parties"("user_id");
CREATE INDEX "parties_account_currency_id_idx" ON "parties"("account_currency_id");
CREATE TABLE "new_umrah_hotel_bookings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "city_id" TEXT NOT NULL,
    "hotel_id" TEXT NOT NULL,
    "checkin_date" DATETIME NOT NULL,
    "checkout_date" DATETIME NOT NULL,
    "brn" JSONB,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_hotel_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_hotel_bookings_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_hotel_bookings_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_umrah_hotel_bookings" ("booking_id", "brn", "checkin_date", "checkout_date", "city_id", "created_at", "hotel_id", "id", "updated_at") SELECT "booking_id", "brn", "checkin_date", "checkout_date", "city_id", "created_at", "hotel_id", "id", "updated_at" FROM "umrah_hotel_bookings";
DROP TABLE "umrah_hotel_bookings";
ALTER TABLE "new_umrah_hotel_bookings" RENAME TO "umrah_hotel_bookings";
CREATE INDEX "umrah_hotel_bookings_booking_id_idx" ON "umrah_hotel_bookings"("booking_id");
CREATE INDEX "umrah_hotel_bookings_city_id_idx" ON "umrah_hotel_bookings"("city_id");
CREATE INDEX "umrah_hotel_bookings_hotel_id_idx" ON "umrah_hotel_bookings"("hotel_id");
CREATE INDEX "umrah_hotel_bookings_checkin_date_idx" ON "umrah_hotel_bookings"("checkin_date");
CREATE INDEX "umrah_hotel_bookings_checkout_date_idx" ON "umrah_hotel_bookings"("checkout_date");
CREATE TABLE "new_umrah_visa_bookings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "party_id" TEXT NOT NULL,
    "submitted_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "group_number" TEXT,
    "group_name" TEXT,
    "passenger_count" INTEGER NOT NULL,
    "umrah_visa_provider_id" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" DATETIME,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "has_group_number" BOOLEAN NOT NULL DEFAULT false,
    "accommodation_type" TEXT,
    "visa_type" TEXT NOT NULL DEFAULT 'individual_visa',
    "has_transportation" BOOLEAN NOT NULL DEFAULT false,
    "voucher_generated_at" DATETIME,
    "voucher_generated_by" TEXT,
    "bill_generated_at" DATETIME,
    "bill_generated_by" TEXT,
    "documents_download_count" INTEGER NOT NULL DEFAULT 0,
    "documents_downloaded_by" TEXT,
    "last_updated_by" TEXT,
    "has_multiple_group" BOOLEAN NOT NULL DEFAULT false,
    "multiple_group_details" JSONB,
    CONSTRAINT "umrah_visa_bookings_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_umrah_visa_provider_id_fkey" FOREIGN KEY ("umrah_visa_provider_id") REFERENCES "parties" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_documents_downloaded_by_fkey" FOREIGN KEY ("documents_downloaded_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_last_updated_by_fkey" FOREIGN KEY ("last_updated_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_umrah_visa_bookings" ("accommodation_type", "bill_generated_at", "bill_generated_by", "created_at", "deleted_at", "documents_download_count", "documents_downloaded_by", "group_name", "group_number", "has_group_number", "has_multiple_group", "has_transportation", "id", "is_deleted", "last_updated_by", "multiple_group_details", "party_id", "passenger_count", "status", "submitted_at", "umrah_visa_provider_id", "updated_at", "visa_type", "voucher_generated_at", "voucher_generated_by") SELECT "accommodation_type", "bill_generated_at", "bill_generated_by", "created_at", "deleted_at", "documents_download_count", "documents_downloaded_by", "group_name", "group_number", "has_group_number", "has_multiple_group", "has_transportation", "id", "is_deleted", "last_updated_by", "multiple_group_details", "party_id", "passenger_count", "status", "submitted_at", "umrah_visa_provider_id", "updated_at", "visa_type", "voucher_generated_at", "voucher_generated_by" FROM "umrah_visa_bookings";
DROP TABLE "umrah_visa_bookings";
ALTER TABLE "new_umrah_visa_bookings" RENAME TO "umrah_visa_bookings";
CREATE INDEX "umrah_visa_bookings_party_id_idx" ON "umrah_visa_bookings"("party_id");
CREATE INDEX "umrah_visa_bookings_status_idx" ON "umrah_visa_bookings"("status");
CREATE INDEX "umrah_visa_bookings_umrah_visa_provider_id_idx" ON "umrah_visa_bookings"("umrah_visa_provider_id");
CREATE INDEX "umrah_visa_bookings_is_deleted_idx" ON "umrah_visa_bookings"("is_deleted");
CREATE INDEX "umrah_visa_bookings_created_at_idx" ON "umrah_visa_bookings"("created_at");
CREATE INDEX "umrah_visa_bookings_has_group_number_idx" ON "umrah_visa_bookings"("has_group_number");
CREATE INDEX "umrah_visa_bookings_accommodation_type_idx" ON "umrah_visa_bookings"("accommodation_type");
CREATE INDEX "umrah_visa_bookings_visa_type_idx" ON "umrah_visa_bookings"("visa_type");
CREATE INDEX "umrah_visa_bookings_has_transportation_idx" ON "umrah_visa_bookings"("has_transportation");
CREATE INDEX "umrah_visa_bookings_submitted_at_idx" ON "umrah_visa_bookings"("submitted_at");
CREATE TABLE "new_user_role_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "role_code" TEXT NOT NULL,
    "role_name" TEXT NOT NULL,
    "permissions" JSONB NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_user_role_masters" ("created_at", "description", "id", "is_active", "permissions", "role_code", "role_name", "updated_at") SELECT "created_at", "description", "id", "is_active", "permissions", "role_code", "role_name", "updated_at" FROM "user_role_masters";
DROP TABLE "user_role_masters";
ALTER TABLE "new_user_role_masters" RENAME TO "user_role_masters";
CREATE UNIQUE INDEX "user_role_masters_role_code_key" ON "user_role_masters"("role_code");
CREATE INDEX "user_role_masters_role_code_idx" ON "user_role_masters"("role_code");
CREATE INDEX "user_role_masters_role_name_idx" ON "user_role_masters"("role_name");
CREATE INDEX "user_role_masters_is_active_idx" ON "user_role_masters"("is_active");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
