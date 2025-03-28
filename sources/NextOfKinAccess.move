module 0x0::NextOfKinAccess {
    public entry fun authorize_critical_access(
        _patient_wallet_id: address,
        _otp: u64,
        _account: &mut TxContext,
    ) {}
}

