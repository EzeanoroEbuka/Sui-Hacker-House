module 0x0::PatientRegistration {

    public struct Patient has key,store {
        id: UID,
        wallet_id: address,
        name: vector<u8>,
        email: vector<u8>,
        next_of_kin: NextOfKin,
    }

    public struct NextOfKin has store {
        name: vector<u8>,
        email: vector<u8>,
        phone: vector<u8>,
    }

    public entry fun register_patient(name: vector<u8>, email: vector<u8>,ctx: &mut TxContext) {
        let id = object::new(ctx);
        let wallet_id = tx_context::sender(ctx);
        let next_of_kin = NextOfKin {
            name: b"Next of Kin Name",
            email: b"nextofkin@example.com",
            phone: b"+1234567890"
        };
        transfer::public_transfer(Patient{
            id,
            wallet_id,
            name,
            email,
            next_of_kin,
        }, wallet_id);
    }




}
