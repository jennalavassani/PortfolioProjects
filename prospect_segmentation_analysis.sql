CREATE TABLE prospect_segmentation (
    company_name TEXT,
    industry TEXT,
    size_category VARCHAR(50),
    contact_department TEXT,
    lead_source TEXT,
    interest_level VARCHAR(20),
    contact_date DATE,
    last_contacted DATE,
    follow_up_action TEXT,
    product_interest TEXT,
    decision_maker TEXT,
    budget VARCHAR(50),
    implementation_timeline VARCHAR(50)
);

-- Lead Source Effectiveness: Identifying high-priority lead sources based on interest level
SELECT lead_source, COUNT(*) AS high_interest_leads
FROM prospect_segmentation
WHERE interest_level = 'High'
GROUP BY lead_source
ORDER BY high_interest_leads DESC;

-- Interest Level by Industry and Size: Explore interest level distribution across industries and company sizes, organized by interest level from high to low
SELECT industry, size_category, interest_level, COUNT(*) AS lead_count
FROM prospect_segmentation
GROUP BY industry, size_category, interest_level
ORDER BY 
    CASE interest_level
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END,
    industry,
    size_category;

-- Follow-Up Action Outcomes: Analyzing the effectiveness of follow-up actions in relation to interest level
SELECT follow_up_action, interest_level, COUNT(*) AS count
FROM prospect_segmentation
GROUP BY follow_up_action, interest_level
ORDER BY follow_up_action, interest_level;

-- Timeline for Outreach: Identifying optimal times for outreach based on contact dates and interest levels
SELECT EXTRACT(MONTH FROM contact_date) AS contact_month, COUNT(*) AS total_contacts,
       SUM(CASE WHEN interest_level = 'High' THEN 1 ELSE 0 END) AS high_interest_contacts
FROM prospect_segmentation
GROUP BY contact_month
ORDER BY contact_month;

-- Budget Insights: Correlating budgets with interest levels to understand financial aspects of leads, including company or contact information
SELECT budget, interest_level, COUNT(*) AS lead_count, company_name, contact_department
FROM prospect_segmentation
GROUP BY budget, interest_level, company_name, contact_department
ORDER BY 
    CASE 
        WHEN interest_level = 'High' THEN 1
        WHEN interest_level = 'Medium' THEN 2
        WHEN interest_level = 'Low' THEN 3
        ELSE 4
    END, 
    budget DESC;

-- Determining Lead Source Priority: Assessing lead source priority based on various factors including interest level and follow-up success
SELECT lead_source,
       COUNT(*) FILTER (WHERE interest_level = 'High') AS high_interest_count,
       COUNT(*) FILTER (WHERE follow_up_action IN ('Schedule demo', 'Send info packet')) AS positive_follow_ups,
       COUNT(*) AS total_leads
FROM prospect_segmentation
GROUP BY lead_source
ORDER BY high_interest_count DESC, positive_follow_ups DESC, total_leads DESC;

