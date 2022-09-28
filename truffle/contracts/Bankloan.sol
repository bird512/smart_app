// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bankloan is Ownable {

    uint public total = 0;
    LoanTerm[] loanList;
    mapping(uint => LenderTerm[]) lenderListMap;

    mapping(uint => Payment[]) loanPayments;
    mapping(uint => mapping(uint => Payment[])) lenderPayments;

    mapping(address => uint[]) userLoans;
    mapping(address => uint[]) userLenders;

    struct LoanTerm {
        address issuer;
        uint maxAmount;
        uint rate;
        uint terms;
        uint amount;
    }

    struct LenderTerm {
        uint loanId;
        address lender;
        uint amount;
    }

    struct Payment{
        uint loanId;
        uint amount;
    }

    event NewLoan(uint indexed loanId,address indexed issuer, uint maxAmount, uint rate, uint terms);
    event PrincipalPay(uint indexed loanId,uint amount);
    event PrincipalReceive(address indexed to,uint indexed loanId,uint amount);

    event InterestPay(uint indexed loanId,uint amount);
    event InterestReceive(address indexed to,uint indexed loanId,uint amount);

    constructor() {
    }

    function registerLoan(uint maxAmount, uint rate, uint terms) public returns (uint) {
        LoanTerm memory loan = LoanTerm(msg.sender,maxAmount,rate,terms, 0);
        loanList.push(loan);
        
        total++;
        return total;
    }
  
    function activeLoan(uint loanId) public returns (uint) {
        LoanTerm storage loan = loanList[loanId];
        require(loan.lender == msg.sender,"!lender");
        emit NewLoan(loan.id,msg.sender, loan.rate,loan.terms, loan.amount);
    }

    function takeLoan(uint loanId, uint amount) public {
        require(loanId<total,"out_of_index");
        require(amount > 0,"!zero_input");
        LoanTerm storage loan = loanList[loanId];
        uint leftAmount = loan.maxAmount - loan.amount;
        require(amount <= leftAmount,"!out_of_max");

        LenderTerm memory lender = LenderTerm(loanId, msg.sender, amount);
        lenderListMap[loanId].push(lender);
        loan.amount = loan.amount + amount;
        //todo send token
    }
    
    function makePrincipalPayment(uint loanId) public {
        require(loanId<total,"out_of_index");
        LoanTerm memory loan = loanList[loanId];
        require(msg.sender == loan.issuer,"!issuer");
        LenderTerm[] memory lenders =  lenderListMap[loanId];
        uint len = lenders.length;
        require(len>0,"no_lender");
        for (uint i = 0; i < len; i++) {
            LenderTerm memory lender = lenders[i];
            //send
            emit PrincipalReceive(lender.lender, loanId, lender.amount);
        }
        emit PrincipalPay(loanId,loan.amount);
    }


    function makeInterestPayment(uint loanId) public {
        require(loanId<total,"out_of_index");
        LoanTerm memory loan = loanList[loanId];
        require(msg.sender == loan.issuer,"!issuer");
        LenderTerm[] memory lenders =  lenderListMap[loanId];
        uint len = lenders.length;
        require(len>0,"no_lender");

        uint amount = loan.amount;
        uint principal = amount*loan.rate/10000/loan.terms;
        uint payedPrinc = 0;
        for (uint i = 0; i < len-1; i++) {
            LenderTerm memory lender = lenders[i];
            uint cPrincipal = principal * lender.amount/amount;
            //send
            emit InterestReceive(lender.lender, loanId, cPrincipal);
            payedPrinc = payedPrinc + cPrincipal;
        }

        LenderTerm memory lastLender = lenders[len-1];
        //send
        emit InterestReceive(lastLender.lender, loanId, principal-payedPrinc);
        emit InterestPay(loanId,amount);
    }

    function getLoans() public view returns (LoanTerm[] memory){
        return loanList;
    }


}