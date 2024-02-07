-- Docs: https://docs.mage.ai/guides/sql-blocks

-- SELECT * FROM mage.green_taxi LIMIT 10;

SELECT 
    vendor_id,
    COUNT(vendor_id) AS count
FROM mage.green_taxi
GROUP BY vendor_id;
