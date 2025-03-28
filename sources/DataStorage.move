module 0x1::DataStorage {


    public struct EncryptedData has key ,store{
        id: UID,
        data: vector<u64>,
    }

    public fun store_data(encrypted_data: vector<u64>,ctx: &mut TxContext) {
        let id = object::new(ctx);
        let sender = tx_context::sender(ctx);
        transfer::public_transfer(EncryptedData { id, data: encrypted_data },sender);

    }
}
