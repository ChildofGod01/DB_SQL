--Q1 How many users does Wave have?
SELECT COUNT(*) FROM users;

--Q2 How many transfers have been sent in the currency CFA?
SELECT COUNT (*) FROM transfers WHERE send_amount_currency='CFA';

--Q3 How many different users have sent a transfer in CFA?
SELECT COUNT(DISTINCT u_id) FROM transfers WHERE send_amount_currency='CFA';

--Q4 How many agent_transactions did we have in the months of 2018?
SELECT TO_CHAR(when_created,'Month') AS "Month",Count(*)
FROM agent_transactions WHERE EXTRACT(YEAR FROM when_created)=2018 GROUP BY "Month";

--Q5 Over the course of the last week, how many Wave agents were “net depositors” vs. “netwithdrawers”? 
SELECT SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS withdrawal,  
SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END) AS deposit,
CASE WHEN ((SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END)) > ((SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END))) * -1) THEN 'withdrawer'
ELSE 'depositer' END AS agent_status, COUNT(*) FROM agent_transactions
WHERE when_created  between (now()  - '1 WEEK'::INTERVAL) and now();

--Q6 
SELECT agents.city, COUNT(amount) FROM agents_transactions INNER JOIN agents 
ON agents.agent_id=agent_transactions.agent_id 
WHERE agent_transactions.when_created > CURRENT_DATE - interval '7 days' GROUP BY agents.city;

--Q7
SELECT COUNT (atx.amount) AS "atx volume",COUNT (agents.city) AS "City",
COUNT (agents.country) AS "Country" FROM agent_transactions AS atx INNER JOIN agents AS agents 
ON atx.atx_id = agents.agent_id GROUP BY agents.country;
	
--Q8
SELECT transfers.kind AS Kind, wallets.ledger_location AS Country,
SUM (transfers.send_amount_scalar) AS Volume FROM transfers 
INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id 
WHERE (transfers.when_created > (NOW() - INTERVAL '1 week')) GROUP BY wallets.ledger_location, transfers.kind;

--Q9
SELECT COUNT (transfers.source_wallet_id) AS Unique_Senders,
COUNT (transfer_id) AS Transaction_Count, transfers.kind AS Transfer_kind, wallets.ledger_location AS Country,
SUM (transfers.send_amount_scalar) AS Volume FROM transfers 
INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id 
WHERE (transfers.when_created > (NOW() - INTERVAL '1 week'))GROUP BY wallets.ledger_location, transfers.kind;

--Q10
SELECT tn.send_amount_scalar,tn.source_wallet_id,w.wallet_id 
FROM transfers AS tn INNER JOIN wallets AS w ON tn.transfer_id = w.wallet_id 
WHERE tn.send_amount_scalar > 10000000 
AND (tn.send_amount_currency = 'CFA' AND tn.when_created> CURRENT_DATE-INTERVAL '1 month')