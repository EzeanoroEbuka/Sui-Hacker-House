module emr_system::Wallet {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const E_INSUFFICIENT_BALANCE: u64 = 0;
    const E_UNAUTHORIZED: u64 = 1;
    const E_INVALID_AMOUNT: u64 = 2;
    const E_WALLET_INACTIVE: u64 = 3;

    public struct Wallet has key, store {
        id: UID,
        owner: address,
        balance: Coin<SUI>,
        active: bool,
    }

    public struct BalanceChecker has drop {
        balance: u64,
        owner: address,
    }

    public struct WalletCreatedEvent has copy, drop {
        wallet_id: address,
        owner: address,
        timestamp: u64,
    }

    public struct DepositEvent has copy, drop {
        wallet_id: address,
        amount: u64,
        timestamp: u64,
    }

    public struct WithdrawEvent has copy, drop {
        wallet_id: address,
        amount: u64,
        recipient: address,
        timestamp: u64,
    }

    public struct TransferToWalletEvent has copy, drop {
        source_wallet_id: address,
        dest_wallet_id: address,
        amount: u64,
        timestamp: u64,
    }

    public struct TransferToAddressEvent has copy, drop {
        source_wallet_id: address,
        recipient: address,
        amount: u64,
        timestamp: u64,
    }

    public struct ReceiveEvent has copy, drop {
        wallet_id: address,
        amount: u64,
        sender: address,
        timestamp: u64,
    }

    public struct ActivationEvent has copy, drop {
        wallet_id: address,
        active: bool,
        timestamp: u64,
    }

    public fun balance_of(wallet: &Wallet): u64 {
        coin::value(&wallet.balance)
    }

    public fun is_active(wallet: &Wallet): bool {
        wallet.active
    }

    public fun owner_of(wallet: &Wallet): address {
        wallet.owner
    }

    public fun get_balance(checker: &BalanceChecker): u64 {
        checker.balance
    }

    public fun get_owner(checker: &BalanceChecker): address {
        checker.owner
    }
    public fun get_wallet_owner(wallet: &Wallet): address {
        wallet.owner
    }
    public fun get_wallet_id(wallet: &Wallet): UID {
        wallet.id
    }

    public fun create_wallet(ctx: &mut TxContext): Wallet {
        let wallet = Wallet {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            balance: coin::zero<SUI>(ctx),
            active: true,
        };
        let wallet_id = object::uid_to_address(&wallet.id);
        event::emit(WalletCreatedEvent {
            wallet_id,
            owner: tx_context::sender(ctx),
            timestamp: tx_context::epoch(ctx),
        });
        transfer::public_transfer(wallet, tx_context::sender(ctx));
        wallet
    }

    public fun create_balance_checker(wallet: &Wallet, _ctx: &mut TxContext): BalanceChecker {
        BalanceChecker {
            balance: coin::value(&wallet.balance),
            owner: wallet.owner,
        }
    }

    public entry fun deposit(wallet: &mut Wallet, coin: Coin<SUI>, ctx: &mut TxContext) {
        assert!(wallet.active, E_WALLET_INACTIVE);
        assert!(tx_context::sender(ctx) == wallet.owner, E_UNAUTHORIZED);
        let amount = coin::value(&coin);
        assert!(amount > 0, E_INVALID_AMOUNT);
        coin::join(&mut wallet.balance, coin);
        event::emit(DepositEvent {
            wallet_id: object::uid_to_address(&wallet.id),
            amount,
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun withdraw(wallet: &mut Wallet, amount: u64, ctx: &mut TxContext) {
        assert!(wallet.active, E_WALLET_INACTIVE);
        assert!(tx_context::sender(ctx) == wallet.owner, E_UNAUTHORIZED);
        assert!(amount > 0, E_INVALID_AMOUNT);
        assert!(coin::value(&wallet.balance) >= amount, E_INSUFFICIENT_BALANCE);
        let withdrawn_coin = coin::split(&mut wallet.balance, amount, ctx);
        let recipient = wallet.owner;
        transfer::public_transfer(withdrawn_coin, recipient);
        event::emit(WithdrawEvent {
            wallet_id: object::uid_to_address(&wallet.id),
            amount,
            recipient,
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun transfer_to_wallet(
        source_wallet: &mut Wallet,
        dest_wallet: &mut Wallet,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(source_wallet.active, E_WALLET_INACTIVE);
        assert!(tx_context::sender(ctx) == source_wallet.owner, E_UNAUTHORIZED);
        assert!(amount > 0, E_INVALID_AMOUNT);
        assert!(coin::value(&source_wallet.balance) >= amount, E_INSUFFICIENT_BALANCE);
        assert!(dest_wallet.active, E_WALLET_INACTIVE);

        let transferred_coin = coin::split(&mut source_wallet.balance, amount, ctx);
        coin::join(&mut dest_wallet.balance, transferred_coin);
        event::emit(TransferToWalletEvent {
            source_wallet_id: object::uid_to_address(&source_wallet.id),
            dest_wallet_id: object::uid_to_address(&dest_wallet.id),
            amount,
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun transfer_to_address(
        source_wallet: &mut Wallet,
        recipient: address,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(source_wallet.active, E_WALLET_INACTIVE);
        assert!(tx_context::sender(ctx) == source_wallet.owner, E_UNAUTHORIZED);
        assert!(amount > 0, E_INVALID_AMOUNT);
        assert!(coin::value(&source_wallet.balance) >= amount, E_INSUFFICIENT_BALANCE);

        let transferred_coin = coin::split(&mut source_wallet.balance, amount, ctx);
        transfer::public_transfer(transferred_coin, recipient);
        event::emit(TransferToAddressEvent {
            source_wallet_id: object::uid_to_address(&source_wallet.id),
            recipient,
            amount,
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun receive(wallet: &mut Wallet, coin: Coin<SUI>, ctx: &mut TxContext) {
        assert!(wallet.active, E_WALLET_INACTIVE);
        assert!(tx_context::sender(ctx) == wallet.owner, E_UNAUTHORIZED);
        let amount = coin::value(&coin);
        assert!(amount > 0, E_INVALID_AMOUNT);
        coin::join(&mut wallet.balance, coin);
        event::emit(ReceiveEvent {
            wallet_id: object::uid_to_address(&wallet.id),
            amount,
            sender: tx_context::sender(ctx),
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun check_balance(wallet: &Wallet, _ctx: &mut TxContext): u64 {
        coin::value(&wallet.balance)
    }

    public entry fun deactivate(wallet: &mut Wallet, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == wallet.owner, E_UNAUTHORIZED);
        wallet.active = false;
        event::emit(ActivationEvent {
            wallet_id: object::uid_to_address(&wallet.id),
            active: false,
            timestamp: tx_context::epoch(ctx),
        });
    }

    public entry fun activate(wallet: &mut Wallet, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == wallet.owner, E_UNAUTHORIZED);
        wallet.active = true;
        event::emit(ActivationEvent {
            wallet_id: object::uid_to_address(&wallet.id),
            active: true,
            timestamp: tx_context::epoch(ctx),
        });
    }
}
