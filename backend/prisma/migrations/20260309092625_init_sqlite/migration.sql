-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "parties" (
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
    "supplier_service_types" TEXT,
    CONSTRAINT "parties_account_currency_id_fkey" FOREIGN KEY ("account_currency_id") REFERENCES "currency_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "parties_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "parties_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_visa_bookings" (
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
    "multiple_group_details" TEXT,
    CONSTRAINT "umrah_visa_bookings_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_umrah_visa_provider_id_fkey" FOREIGN KEY ("umrah_visa_provider_id") REFERENCES "parties" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_documents_downloaded_by_fkey" FOREIGN KEY ("documents_downloaded_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "umrah_visa_bookings_last_updated_by_fkey" FOREIGN KEY ("last_updated_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_passengers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "is_lead_passenger" BOOLEAN NOT NULL DEFAULT false,
    "full_name" TEXT NOT NULL,
    "nationality" TEXT,
    "passport_number" TEXT,
    "entry_date" DATETIME,
    "exit_date" DATETIME,
    "visa_number" TEXT,
    "mofa_number" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" DATETIME,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "umrah_passengers_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "documents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "file_path" TEXT NOT NULL,
    "fileSize" INTEGER,
    "mime_type" TEXT,
    "uploaded_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "passenger_id" TEXT,
    "deleted_at" DATETIME,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "documents_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires_at" DATETIME NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "booking_status_history" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "old_status" TEXT,
    "new_status" TEXT NOT NULL,
    "changed_by" TEXT NOT NULL,
    "reason" TEXT,
    "changed_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" DATETIME,
    CONSTRAINT "booking_status_history_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "booking_status_history_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "entity_type" TEXT NOT NULL,
    "entity_id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "old_values" TEXT,
    "new_values" TEXT,
    "changed_by" TEXT NOT NULL,
    "changed_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ip_address" TEXT,
    "user_agent" TEXT,
    CONSTRAINT "audit_logs_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "cancellation_policies" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "days_before_travel" INTEGER NOT NULL,
    "cancellation_fee" DECIMAL NOT NULL,
    "refund_percentage" DECIMAL NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "vehicle_type_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "vehicle_name" TEXT NOT NULL,
    "pax_count" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "currency_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "currency_code" TEXT NOT NULL,
    "currency_name" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "country_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "country_code" TEXT NOT NULL,
    "country_name" TEXT NOT NULL,
    "currency_code" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "city_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "country_id" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "city_masters_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "country_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "location_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location_type" TEXT NOT NULL,
    "country_id" TEXT NOT NULL,
    "city_id" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "location_masters_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "country_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "location_masters_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "user_role_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "role_code" TEXT NOT NULL,
    "role_name" TEXT NOT NULL,
    "permissions" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "transport_route_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "city1_id" TEXT NOT NULL,
    "city2_id" TEXT NOT NULL,
    "city3_id" TEXT,
    "city4_id" TEXT,
    "route_type" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "transport_route_masters_city1_id_fkey" FOREIGN KEY ("city1_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "transport_route_masters_city2_id_fkey" FOREIGN KEY ("city2_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "transport_route_masters_city3_id_fkey" FOREIGN KEY ("city3_id") REFERENCES "city_masters" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "transport_route_masters_city4_id_fkey" FOREIGN KEY ("city4_id") REFERENCES "city_masters" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "transport_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "route_id" TEXT NOT NULL,
    "vehicle_type_id" TEXT NOT NULL,
    "price" DECIMAL NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "transport_masters_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "transport_route_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "transport_masters_vehicle_type_id_fkey" FOREIGN KEY ("vehicle_type_id") REFERENCES "vehicle_type_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_travel_details" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "arrival_datetime" DATETIME NOT NULL,
    "arrival_airport_id" TEXT NOT NULL,
    "arrival_flight_number" TEXT NOT NULL,
    "departure_datetime" DATETIME NOT NULL,
    "departure_airport_id" TEXT NOT NULL,
    "departure_flight_number" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_travel_details_arrival_airport_id_fkey" FOREIGN KEY ("arrival_airport_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_travel_details_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_travel_details_departure_airport_id_fkey" FOREIGN KEY ("departure_airport_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_hotel_bookings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "city_id" TEXT NOT NULL,
    "hotel_id" TEXT NOT NULL,
    "checkin_date" DATETIME NOT NULL,
    "checkout_date" DATETIME NOT NULL,
    "brn" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_hotel_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_hotel_bookings_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_hotel_bookings_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_sponser_iqama_details" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "iqama_sponser_name" TEXT NOT NULL,
    "iqama_number" TEXT NOT NULL,
    "sponser_dob" DATETIME NOT NULL,
    "sponser_mobile_number" TEXT NOT NULL,
    "sponser_national_short_address" TEXT NOT NULL,
    "confirmation_image_path" TEXT,
    "confirmation_uploaded_at" DATETIME,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_sponser_iqama_details_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_transport_bookings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "transport_master_id" TEXT NOT NULL,
    "travel_datetime" DATETIME,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_transport_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_transport_bookings_transport_master_id_fkey" FOREIGN KEY ("transport_master_id") REFERENCES "transport_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_movement_details" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "booking_id" TEXT NOT NULL,
    "travel_datetime" DATETIME NOT NULL,
    "from_city_id" TEXT NOT NULL,
    "from_location_id" TEXT NOT NULL,
    "to_city_id" TEXT NOT NULL,
    "to_location_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "umrah_movement_details_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "umrah_visa_bookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "umrah_movement_details_from_city_id_fkey" FOREIGN KEY ("from_city_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_movement_details_from_location_id_fkey" FOREIGN KEY ("from_location_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_movement_details_to_city_id_fkey" FOREIGN KEY ("to_city_id") REFERENCES "city_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "umrah_movement_details_to_location_id_fkey" FOREIGN KEY ("to_location_id") REFERENCES "location_masters" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "passenger_documents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "passenger_id" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "file_path" TEXT NOT NULL,
    "fileSize" INTEGER,
    "mime_type" TEXT,
    "uploaded_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" DATETIME,
    CONSTRAINT "passenger_documents_passenger_id_fkey" FOREIGN KEY ("passenger_id") REFERENCES "umrah_passengers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "vouchers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "voucher_number" TEXT NOT NULL,
    "reservation_date" DATETIME NOT NULL,
    "guest_name" TEXT NOT NULL,
    "guest_mobile" TEXT,
    "group_code" TEXT,
    "group_name" TEXT,
    "umrah_visa_provider_id" TEXT,
    "pax_count" INTEGER NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "generated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "generated_by" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "vouchers_generated_by_fkey" FOREIGN KEY ("generated_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "voucher_movements" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "voucher_id" TEXT NOT NULL,
    "sr" INTEGER NOT NULL,
    "route" TEXT,
    "date" DATETIME NOT NULL,
    "time" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "from_location" TEXT NOT NULL,
    "from_location_id" TEXT,
    "to" TEXT NOT NULL,
    "to_location" TEXT NOT NULL,
    "to_location_id" TEXT,
    "driver_details_1" TEXT,
    "driver_details_2" TEXT,
    "vehicle_number" TEXT,
    "pax_count" INTEGER,
    "price" DECIMAL,
    "vehicle_type" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "voucher_movements_voucher_id_fkey" FOREIGN KEY ("voucher_id") REFERENCES "vouchers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "voucher_hotels" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "voucher_id" TEXT NOT NULL,
    "number" INTEGER NOT NULL,
    "location" TEXT NOT NULL,
    "hotel_name" TEXT NOT NULL,
    "check_in" DATETIME NOT NULL,
    "check_out" DATETIME NOT NULL,
    "days" INTEGER NOT NULL,
    "brn" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "voucher_hotels_voucher_id_fkey" FOREIGN KEY ("voucher_id") REFERENCES "vouchers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "voucher_flights" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "voucher_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "carrier" TEXT NOT NULL,
    "number" TEXT NOT NULL,
    "date" DATETIME NOT NULL,
    "from" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    "etd" TEXT,
    "eta" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "voucher_flights_voucher_id_fkey" FOREIGN KEY ("voucher_id") REFERENCES "vouchers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "party_contacts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "party_id" TEXT NOT NULL,
    "contact_name" TEXT NOT NULL,
    "contact_number" TEXT NOT NULL,
    "department" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "party_contacts_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "party_documents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "party_id" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "file_path" TEXT NOT NULL,
    "file_size" INTEGER,
    "mime_type" TEXT,
    "uploaded_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" DATETIME,
    CONSTRAINT "party_documents_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "pricing_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "party_id" TEXT NOT NULL,
    "cost" DECIMAL NOT NULL,
    "price" DECIMAL NOT NULL,
    "type" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pricing_masters_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "umrah_visa_masters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "last_arrival_date" DATETIME NOT NULL,
    "last_departure_date" DATETIME NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE UNIQUE INDEX "parties_party_code_key" ON "parties"("party_code");

-- CreateIndex
CREATE UNIQUE INDEX "parties_email_key" ON "parties"("email");

-- CreateIndex
CREATE UNIQUE INDEX "parties_user_id_key" ON "parties"("user_id");

-- CreateIndex
CREATE INDEX "parties_email_idx" ON "parties"("email");

-- CreateIndex
CREATE INDEX "parties_party_name_idx" ON "parties"("party_name");

-- CreateIndex
CREATE INDEX "parties_party_code_idx" ON "parties"("party_code");

-- CreateIndex
CREATE INDEX "parties_customer_type_idx" ON "parties"("customer_type");

-- CreateIndex
CREATE INDEX "parties_user_id_idx" ON "parties"("user_id");

-- CreateIndex
CREATE INDEX "parties_account_currency_id_idx" ON "parties"("account_currency_id");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_party_id_idx" ON "umrah_visa_bookings"("party_id");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_status_idx" ON "umrah_visa_bookings"("status");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_umrah_visa_provider_id_idx" ON "umrah_visa_bookings"("umrah_visa_provider_id");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_is_deleted_idx" ON "umrah_visa_bookings"("is_deleted");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_created_at_idx" ON "umrah_visa_bookings"("created_at");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_has_group_number_idx" ON "umrah_visa_bookings"("has_group_number");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_accommodation_type_idx" ON "umrah_visa_bookings"("accommodation_type");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_visa_type_idx" ON "umrah_visa_bookings"("visa_type");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_has_transportation_idx" ON "umrah_visa_bookings"("has_transportation");

-- CreateIndex
CREATE INDEX "umrah_visa_bookings_submitted_at_idx" ON "umrah_visa_bookings"("submitted_at");

-- CreateIndex
CREATE INDEX "umrah_passengers_booking_id_idx" ON "umrah_passengers"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_passengers_is_lead_passenger_idx" ON "umrah_passengers"("is_lead_passenger");

-- CreateIndex
CREATE INDEX "umrah_passengers_is_deleted_idx" ON "umrah_passengers"("is_deleted");

-- CreateIndex
CREATE INDEX "documents_booking_id_idx" ON "documents"("booking_id");

-- CreateIndex
CREATE INDEX "documents_passenger_id_idx" ON "documents"("passenger_id");

-- CreateIndex
CREATE INDEX "documents_document_type_idx" ON "documents"("document_type");

-- CreateIndex
CREATE INDEX "documents_is_deleted_idx" ON "documents"("is_deleted");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_key" ON "refresh_tokens"("token");

-- CreateIndex
CREATE INDEX "refresh_tokens_user_id_idx" ON "refresh_tokens"("user_id");

-- CreateIndex
CREATE INDEX "refresh_tokens_token_idx" ON "refresh_tokens"("token");

-- CreateIndex
CREATE INDEX "booking_status_history_booking_id_idx" ON "booking_status_history"("booking_id");

-- CreateIndex
CREATE INDEX "booking_status_history_changed_by_idx" ON "booking_status_history"("changed_by");

-- CreateIndex
CREATE INDEX "booking_status_history_changed_at_idx" ON "booking_status_history"("changed_at");

-- CreateIndex
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "audit_logs_changed_by_idx" ON "audit_logs"("changed_by");

-- CreateIndex
CREATE INDEX "audit_logs_changed_at_idx" ON "audit_logs"("changed_at");

-- CreateIndex
CREATE INDEX "cancellation_policies_is_active_idx" ON "cancellation_policies"("is_active");

-- CreateIndex
CREATE INDEX "cancellation_policies_days_before_travel_idx" ON "cancellation_policies"("days_before_travel");

-- CreateIndex
CREATE UNIQUE INDEX "vehicle_type_masters_vehicle_name_key" ON "vehicle_type_masters"("vehicle_name");

-- CreateIndex
CREATE INDEX "vehicle_type_masters_vehicle_name_idx" ON "vehicle_type_masters"("vehicle_name");

-- CreateIndex
CREATE INDEX "vehicle_type_masters_pax_count_idx" ON "vehicle_type_masters"("pax_count");

-- CreateIndex
CREATE INDEX "vehicle_type_masters_is_active_idx" ON "vehicle_type_masters"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "currency_masters_currency_code_key" ON "currency_masters"("currency_code");

-- CreateIndex
CREATE INDEX "currency_masters_currency_code_idx" ON "currency_masters"("currency_code");

-- CreateIndex
CREATE INDEX "currency_masters_currency_name_idx" ON "currency_masters"("currency_name");

-- CreateIndex
CREATE INDEX "currency_masters_is_active_idx" ON "currency_masters"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "country_masters_country_code_key" ON "country_masters"("country_code");

-- CreateIndex
CREATE INDEX "country_masters_country_code_idx" ON "country_masters"("country_code");

-- CreateIndex
CREATE INDEX "country_masters_country_name_idx" ON "country_masters"("country_name");

-- CreateIndex
CREATE INDEX "country_masters_is_active_idx" ON "country_masters"("is_active");

-- CreateIndex
CREATE INDEX "city_masters_name_idx" ON "city_masters"("name");

-- CreateIndex
CREATE INDEX "city_masters_country_id_idx" ON "city_masters"("country_id");

-- CreateIndex
CREATE INDEX "city_masters_is_active_idx" ON "city_masters"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "city_masters_name_country_id_key" ON "city_masters"("name", "country_id");

-- CreateIndex
CREATE INDEX "location_masters_code_idx" ON "location_masters"("code");

-- CreateIndex
CREATE INDEX "location_masters_name_idx" ON "location_masters"("name");

-- CreateIndex
CREATE INDEX "location_masters_location_type_idx" ON "location_masters"("location_type");

-- CreateIndex
CREATE INDEX "location_masters_country_id_idx" ON "location_masters"("country_id");

-- CreateIndex
CREATE INDEX "location_masters_city_id_idx" ON "location_masters"("city_id");

-- CreateIndex
CREATE INDEX "location_masters_is_active_idx" ON "location_masters"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "location_masters_code_location_type_key" ON "location_masters"("code", "location_type");

-- CreateIndex
CREATE UNIQUE INDEX "user_role_masters_role_code_key" ON "user_role_masters"("role_code");

-- CreateIndex
CREATE INDEX "user_role_masters_role_code_idx" ON "user_role_masters"("role_code");

-- CreateIndex
CREATE INDEX "user_role_masters_role_name_idx" ON "user_role_masters"("role_name");

-- CreateIndex
CREATE INDEX "user_role_masters_is_active_idx" ON "user_role_masters"("is_active");

-- CreateIndex
CREATE INDEX "transport_route_masters_city1_id_idx" ON "transport_route_masters"("city1_id");

-- CreateIndex
CREATE INDEX "transport_route_masters_city2_id_idx" ON "transport_route_masters"("city2_id");

-- CreateIndex
CREATE INDEX "transport_route_masters_route_type_idx" ON "transport_route_masters"("route_type");

-- CreateIndex
CREATE INDEX "transport_route_masters_is_active_idx" ON "transport_route_masters"("is_active");

-- CreateIndex
CREATE INDEX "transport_masters_route_id_idx" ON "transport_masters"("route_id");

-- CreateIndex
CREATE INDEX "transport_masters_vehicle_type_id_idx" ON "transport_masters"("vehicle_type_id");

-- CreateIndex
CREATE INDEX "transport_masters_is_active_idx" ON "transport_masters"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "transport_masters_route_id_vehicle_type_id_key" ON "transport_masters"("route_id", "vehicle_type_id");

-- CreateIndex
CREATE UNIQUE INDEX "umrah_travel_details_booking_id_key" ON "umrah_travel_details"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_travel_details_booking_id_idx" ON "umrah_travel_details"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_travel_details_arrival_datetime_idx" ON "umrah_travel_details"("arrival_datetime");

-- CreateIndex
CREATE INDEX "umrah_travel_details_departure_datetime_idx" ON "umrah_travel_details"("departure_datetime");

-- CreateIndex
CREATE INDEX "umrah_travel_details_arrival_airport_id_idx" ON "umrah_travel_details"("arrival_airport_id");

-- CreateIndex
CREATE INDEX "umrah_travel_details_departure_airport_id_idx" ON "umrah_travel_details"("departure_airport_id");

-- CreateIndex
CREATE INDEX "umrah_hotel_bookings_booking_id_idx" ON "umrah_hotel_bookings"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_hotel_bookings_city_id_idx" ON "umrah_hotel_bookings"("city_id");

-- CreateIndex
CREATE INDEX "umrah_hotel_bookings_hotel_id_idx" ON "umrah_hotel_bookings"("hotel_id");

-- CreateIndex
CREATE INDEX "umrah_hotel_bookings_checkin_date_idx" ON "umrah_hotel_bookings"("checkin_date");

-- CreateIndex
CREATE INDEX "umrah_hotel_bookings_checkout_date_idx" ON "umrah_hotel_bookings"("checkout_date");

-- CreateIndex
CREATE UNIQUE INDEX "umrah_sponser_iqama_details_booking_id_key" ON "umrah_sponser_iqama_details"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_sponser_iqama_details_booking_id_idx" ON "umrah_sponser_iqama_details"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_sponser_iqama_details_iqama_number_idx" ON "umrah_sponser_iqama_details"("iqama_number");

-- CreateIndex
CREATE INDEX "umrah_transport_bookings_booking_id_idx" ON "umrah_transport_bookings"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_transport_bookings_transport_master_id_idx" ON "umrah_transport_bookings"("transport_master_id");

-- CreateIndex
CREATE INDEX "umrah_transport_bookings_travel_datetime_idx" ON "umrah_transport_bookings"("travel_datetime");

-- CreateIndex
CREATE INDEX "umrah_movement_details_booking_id_idx" ON "umrah_movement_details"("booking_id");

-- CreateIndex
CREATE INDEX "umrah_movement_details_travel_datetime_idx" ON "umrah_movement_details"("travel_datetime");

-- CreateIndex
CREATE INDEX "umrah_movement_details_from_city_id_idx" ON "umrah_movement_details"("from_city_id");

-- CreateIndex
CREATE INDEX "umrah_movement_details_to_city_id_idx" ON "umrah_movement_details"("to_city_id");

-- CreateIndex
CREATE INDEX "passenger_documents_passenger_id_idx" ON "passenger_documents"("passenger_id");

-- CreateIndex
CREATE INDEX "passenger_documents_document_type_idx" ON "passenger_documents"("document_type");

-- CreateIndex
CREATE INDEX "passenger_documents_is_deleted_idx" ON "passenger_documents"("is_deleted");

-- CreateIndex
CREATE INDEX "vouchers_voucher_number_idx" ON "vouchers"("voucher_number");

-- CreateIndex
CREATE INDEX "vouchers_generated_at_idx" ON "vouchers"("generated_at");

-- CreateIndex
CREATE INDEX "vouchers_generated_by_idx" ON "vouchers"("generated_by");

-- CreateIndex
CREATE UNIQUE INDEX "vouchers_voucher_number_key" ON "vouchers"("voucher_number");

-- CreateIndex
CREATE INDEX "voucher_movements_voucher_id_idx" ON "voucher_movements"("voucher_id");

-- CreateIndex
CREATE INDEX "voucher_movements_date_idx" ON "voucher_movements"("date");

-- CreateIndex
CREATE INDEX "voucher_movements_from_location_id_idx" ON "voucher_movements"("from_location_id");

-- CreateIndex
CREATE INDEX "voucher_movements_to_location_id_idx" ON "voucher_movements"("to_location_id");

-- CreateIndex
CREATE INDEX "voucher_hotels_voucher_id_idx" ON "voucher_hotels"("voucher_id");

-- CreateIndex
CREATE INDEX "voucher_hotels_check_in_idx" ON "voucher_hotels"("check_in");

-- CreateIndex
CREATE INDEX "voucher_hotels_check_out_idx" ON "voucher_hotels"("check_out");

-- CreateIndex
CREATE INDEX "voucher_flights_voucher_id_idx" ON "voucher_flights"("voucher_id");

-- CreateIndex
CREATE INDEX "voucher_flights_date_idx" ON "voucher_flights"("date");

-- CreateIndex
CREATE INDEX "voucher_flights_type_idx" ON "voucher_flights"("type");

-- CreateIndex
CREATE INDEX "party_contacts_party_id_idx" ON "party_contacts"("party_id");

-- CreateIndex
CREATE INDEX "party_documents_party_id_idx" ON "party_documents"("party_id");

-- CreateIndex
CREATE INDEX "party_documents_document_type_idx" ON "party_documents"("document_type");

-- CreateIndex
CREATE INDEX "party_documents_is_deleted_idx" ON "party_documents"("is_deleted");

-- CreateIndex
CREATE INDEX "pricing_masters_party_id_idx" ON "pricing_masters"("party_id");

-- CreateIndex
CREATE INDEX "pricing_masters_type_idx" ON "pricing_masters"("type");

-- CreateIndex
CREATE INDEX "pricing_masters_is_active_idx" ON "pricing_masters"("is_active");

-- CreateIndex
CREATE INDEX "umrah_visa_masters_is_active_idx" ON "umrah_visa_masters"("is_active");
