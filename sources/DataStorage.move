module 0x1::DataStorage {
    public struct EncryptedData has key {
        data: vector<u8>,
    }

    public entry fun store_data(account: &signer, encrypted_data: vector<u8>) {
        move_to(account, EncryptedData { data: encrypted_data });
    }
}
