module 0x1::AccessControl {
    public struct AccessLevel has copy, drop {
        can_view_public: bool,
        can_view_sensitive: bool,
    }

    public entry fun set_access_level(account: &signer, next_of_kin_email: vector<u8>, level: AccessLevel) {
        // Logic to associate access level with next of kin
    }
}
