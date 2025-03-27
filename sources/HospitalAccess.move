module 0x1::HospitalAccess {
    public entry fun request_patient_data(
        account: &signer,
        patient_wallet_id: address,
        otp: u64
    ) returns (vector<u8>) {}
}
