const Bankloan = artifacts.require("Bankloan");

contract('Bankloan', () => {
  it('should read newly written values', async() => {
    const bankloanInstance = await Bankloan.deployed();
    await bankloanInstance.registerLoan.call(1000,1,1);
    // console.log('register1 = ',register1);
    await bankloanInstance.registerLoan(1000,1,1);
    var total = (await bankloanInstance.total.call()).toNumber();
    assert.equal(total, 1, "registerLoan fail");
    await bankloanInstance.registerLoan(12000,1,1);
    var total2 = (await bankloanInstance.total.call()).toNumber();
    assert.equal(total2, 2, "registerLoan fail");

    var getValue = (await bankloanInstance.getLoans.call());
    console.log('getValue = ',getValue);

    await bankloanInstance.takeLoan(0,200);

  });
});
