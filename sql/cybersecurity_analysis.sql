CREATE TABLE cybersecurity_incidents (
    event_id VARCHAR(50),
    event_timestamp TIMESTAMP,
    source_ip VARCHAR(50),
    destination_ip VARCHAR(50),
    user_agent TEXT,
    attack_type VARCHAR(50),
    attack_severity VARCHAR(20),
    data_exfiltrated BOOLEAN,
    threat_intelligence TEXT,
    response_action VARCHAR(50)
);

select * from cybersecurity_incidents limit 10;

--(1) total incidents--
select count (*) as Total_Incidents
from cybersecurity_incidents;

--(2) attack type distribution--
select attack_type,
count (*) as Incidents
from cybersecurity_incidents
group by attack_type
order by incidents desc;

--(3) attack severnity
select attack_severity,
count(*) AS Incidents
from cybersecurity_incidents
group by attack_severity
order by Incidents desc;

--(4) response action--
SELECT
    response_action,
    COUNT(*) AS incidents
FROM cybersecurity_incidents
GROUP BY response_action
ORDER BY incidents DESC;

--(5) data_exfiltrated--
select data_exfiltrated,
count (*) as incidents
from cybersecurity_incidents
group by data_exfiltrated;

--(6) Attack vs severity-
select
attack_type,
attack_severity,
count (*) as Incidents
from cybersecurity_incidents
group by attack_type, attack_severity
order by attack_type;

--(7) attack types causing data thefts

select
attack_type,
count(*) as exfiltration_cases
from cybersecurity_incidents
where data_exfiltrated = true
group by attack_type
order by exfiltration_cases desc;

--(8) severity of data thefts--

select
attack_severity,
count(*) as exfiltration_cases
from cybersecurity_incidents
where data_exfiltrated = true
group by attack_severity
order by exfiltration_cases desc;

--(9) response actions for data thefts--

select
response_action,
count(*) as incidents
from cybersecurity_incidents
where data_exfiltrated = true
group by response_action
order by incidents desc;

--(10) top IP

select 
source_ip,
count (*) as Incidents
from cybersecurity_incidents
group by source_ip
order by Incidents
LIMIT 10;

--(11) top destination IP--

SELECT
    destination_ip,
    COUNT(*) AS incidents
FROM cybersecurity_incidents
GROUP BY destination_ip
ORDER BY incidents DESC
LIMIT 10;

--(12) extract year from timestamp--

select 
extract (year from event_timestamp) as year,
count(*) as Incidents
from cybersecurity_incidents
group by year
order by year;

--(13) extract month from timestamp
SELECT
    EXTRACT(MONTH FROM event_timestamp) AS month,
    COUNT(*) AS incidents
FROM cybersecurity_incidents
GROUP BY month
ORDER BY month

--(14) CASE WHEN--
SELECT
    attack_type,
    CASE
        WHEN attack_severity = 'High' THEN 'HIGH RISK'
        WHEN attack_severity = 'Critical' THEN 'HIGH RISK'
        ELSE 'NORMAL RISK'
    END AS risk_category,
    COUNT(*) AS incidents
FROM cybersecurity_incidents
GROUP BY attack_type, risk_category
ORDER BY attack_type;

--(15) Having Query

select attack_type,
count(*) as Incidents
from cybersecurity_incidents
group by attack_type
having count(*) > 3000
order by incidents desc;


---(16) CTE Query--
with attack_summary as
(
select attack_type,
count(*) as incidents
from cybersecurity_incidents
group by attack_type
)

select * from attack_summary
where incidents > 3000;

--(17) sub query--
select * from
(
select attack_type,
count(*) as incidents
from cybersecurity_incidents
group by attack_type
)as attack_summary

where incidents >
(
 select AVG(incidents)
 from
 (
   select attack_type,
   count (*) as incidents
   from cybersecurity_incidents
   group by attack_type

 ) as temp
);

--(18)First window function(ROW N0)--
select attack_type,
count(*) as incidents,
ROW_NUMBER() OVER
(
order by count(*) desc
) as row_num
from cybersecurity_incidents
group by attack_type

---(19)window function(rank no)

SELECT
    attack_type,
    COUNT(*) AS incidents,
    RANK() OVER
    (
        ORDER BY COUNT(*) DESC
    ) AS rank_num
FROM cybersecurity_incidents
GROUP BY attack_type;

--(20)window function (dense rank)--

SELECT
    attack_type,
    COUNT(*) AS incidents,
    DENSE_RANK() OVER
    (
        ORDER BY COUNT(*) DESC
    ) AS dense_rank_num
FROM cybersecurity_incidents
GROUP BY attack_type;

--(21) partiton function--
select
attack_type,
attack_severity,
count(*) as incidents,
ROW_NUMBER() OVER
(
partition by attack_severity
order by count(*) desc
)as Severity_Rank
from cybersecurity_incidents
group by attack_severity, attack_type;

--(22) top attack in each severity--
with ranked_attacks as(
select
attack_type,
attack_severity,
count(*) as incidents,
ROW_NUMBER() OVER
(
partition by attack_severity
order by count(*) desc
)as rn
from cybersecurity_incidents
group by attack_severity, attack_type
)

select * from ranked_attacks
where rn= 1