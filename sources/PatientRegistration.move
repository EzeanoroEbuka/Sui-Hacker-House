module 0x0::PatientRegistration {

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use emr_system::Wallet;

    const E_UNAUTHORIZED: u64 = 1;


    public struct Patient has key,store {
        id: UID,
        owner: address,
        name: vector<u8>,
        email: vector<u8>,
        wallet: UID,

    }

    public entry fun register_patient(name: vector<u8>, email: vector<u8>, ctx: &mut TxContext) {
        let patient_id = object::new(ctx);
        let wallet = Wallet::create_wallet(ctx);

        let patient = Patient {
            id: patient_id,
            owner: tx_context::sender(ctx),
            name,
            email,
            wallet: Wallet::get_wallet_id(&wallet)
        };
        transfer::public_transfer(patient, tx_context::sender(ctx));
    }

    public  fun get_patient(patient:&Patient): vector<u8>{
        patient.name
    }


    public  fun get_email(patient: &Patient): vector<u8>{
        patient.email
    }

    public entry fun update_patient_wallet(patient: &mut Patient, wallet: &Wallet::Wallet, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == patient.owner, E_UNAUTHORIZED);
        assert!(tx_context::sender(ctx) == Wallet::get_wallet_owner(wallet), E_UNAUTHORIZED);
        patient.wallet = Wallet::get_wallet_id(Wallet);
    }

    public entry fun update_patient(patient: &mut Patient, name: vector<u8>, email: vector<u8>, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == patient.owner, E_UNAUTHORIZED);
        patient.name = name;
        patient.email = email;
    }
}
