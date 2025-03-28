module 0x1::AccessControl {
    #[allow(unused_field)]
    public struct AccessLevel has copy, drop {
        can_view_public: bool,
        can_view_sensitive: bool,
    }

    public fun set_access_level(_next_of_kin_email: vector<u8>, _level: AccessLevel,_account: &mut TxContext) {}
}
