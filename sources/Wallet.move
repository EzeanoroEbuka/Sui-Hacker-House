module emr_system::Wallet {

    public struct Wallet has key, store {
        id:UID,
        owner: address,
        balance: u256

    }

    public fun create_wallet(ctx: &mut TxContext): Wallet {
        Wallet {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            balance: 0
        }
    }
    public fun get_address(wallet: &Wallet) : address{
        wallet.owner
    }

    public fun get_balance(wallet: &Wallet): u256{
        wallet.balance
    }

    public fun deposit_wallet(amount: u256, wallet: &mut Wallet): &Wallet{

        wallet.balance  = wallet.balance + amount;
        return wallet
    }
}

