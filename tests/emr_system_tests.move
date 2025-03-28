
#[test_only]
module emr_system::emr_system_tests;
use emr_system::Wallet;
use sui::test_scenario;


#[test]
fun test_wallet_is_created() {
    let sender_address = @0x23;
    let mut scenario = test_scenario::begin(sender_address);
    let  mock_context = test_scenario::ctx(&mut scenario);

    let wallet = Wallet::create_wallet(mock_context);

    assert!(Wallet::get_balance(&wallet) >= 0,200);
    assert!(Wallet::get_address(&wallet) == mock_context.sender(),200);

    sui::transfer::public_transfer(wallet, mock_context.sender());
    test_scenario::end(scenario);
}

#[test]

fun test_deposit_into_wallet(){
    let sender_address = @0x987;
    let mut scenario = test_scenario::begin(sender_address);
    let  context = test_scenario::ctx(&mut scenario);

    let amount: u256 = 500;
    let mut new_wallet = Wallet::create_wallet(context);
    let wallet = Wallet::deposit_wallet(amount,&mut new_wallet);

    assert!(Wallet::get_balance(wallet) <= amount,200);
    assert!(Wallet::get_address(wallet) == context.sender(),200);
    sui::transfer::public_transfer(new_wallet, context.sender());
    test_scenario::end(scenario);

}

//
// #[test, expected_failure(abort_code = ::emr_system::emr_system_tests::ENotImplemented)]
// fun test_emr_system_fail() {
//     abort ENotImplemented
// }

