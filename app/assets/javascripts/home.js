(function() {
    'use strict';

    function dashboardRequest() {
        Rails.ajax({
            url: '/',
            type: 'get',
            data: {},
            dataType: 'json',
            beforeSend: function() { return true; },
            success: function(data) {
                try {
                    const expensesIncome = Chartkick.charts["expenses_income"];
                    const balance = Chartkick.charts["balance"];
                    expensesIncome.updateData(data.expenses_incomes_data);
                    balance.updateData(data.balance_data);
                } catch (error) {
                    console.error(error);
                } finally {
                    setTimeout(dashboardRequest, 1000);
                }
            },
            error: function(error) { console.log(error); }
        });
    }
    dashboardRequest();
})()