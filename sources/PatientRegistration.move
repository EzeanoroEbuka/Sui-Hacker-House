module 0x1::PatientRegistration {
    public struct Patient has key {
        wallet_id: address,
        name: vector<u8>,
        email: vector<u8>,
        next_of_kin: NextOfKin,
    }

    public struct NextOfKin has key {
        name: vector<u8>,
        email: vector<u8>,
        phone: vector<u8>,
    }

    public entry fun register_patient(account: &signer, name: vector<u8>, email: vector<u8>) {
        let wallet_id = signer::address_of(account);
        let next_of_kin = NextOfKin {
            name: b"Next of Kin Name",
            email: b"nextofkin@example.com",
            phone: b"+1234567890"
        };
        move_to(account, Patient {
            wallet_id,
            name,
            email,
            next_of_kin
        });
    }
}
