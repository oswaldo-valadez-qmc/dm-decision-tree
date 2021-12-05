SHOW PROCEDURE STATUS  WHERE db = 'decision_tree';

-- PROCEDURE 1R
DROP PROCEDURE IF EXISTS 1R;
DELIMITER $$
CREATE PROCEDURE 1R(
    input_attr varchar(50),
    input_value int,
    output_attr varchar(50),
    acc_enough float,
    cond varchar(1024)
)
BEGIN
    DECLARE input_attr_alias varchar(50) DEFAULT input_attr;
    DECLARE full_cond varchar(1044) DEFAULT '';

    IF input_value IS NOT NULL THEN
      SET input_attr_alias = CONCAT('lte', input_value);
      SET input_attr = CONCAT('IF(', input_attr, ' <= ', input_value, ', 1, 0) AS lte', input_value);
    END IF;

    IF cond IS NOT NULL THEN
      SET full_cond = CONCAT('WHERE ', cond);
    END IF;

    SET @query=CONCAT('
        SELECT 
          ', input_attr_alias, ', 
          ', output_attr, ', 
          match_rows, 
          SUM(match_rows) AS total_rows, 
          match_rows/SUM(match_rows) AS prob, 
          overall_acc, 
          N, 
          goodness 
        FROM (
            SELECT 
              ', input_attr, ', 
              ', output_attr, ', 
              COUNT(*) AS match_rows 
            FROM games
            ', full_cond, ' 
            GROUP BY ', input_attr_alias, ', ', output_attr, ' 
            ORDER BY match_rows DESC
        ) AS count_rows 
        JOIN (
            SELECT 
              SUM(match_rows)/SUM(total_rows) AS overall_acc, 
              SUM(IF(prob < ', acc_enough, ', 1, 0)) as N, 
              (SUM(match_rows)/SUM(total_rows))/SUM(IF(prob < ', acc_enough, ', 1, 0)) AS goodness 
            FROM (
                SELECT 
                  ', input_attr_alias, ', 
                  ', output_attr, ', 
                  match_rows, 
                  SUM(match_rows) AS total_rows, 
                  match_rows/SUM(match_rows) AS prob 
                FROM (
                    SELECT 
                      ', input_attr, ', 
                      ', output_attr, ', 
                      COUNT(*) AS match_rows 
                    FROM games
                    ', full_cond, ' 
                    GROUP BY ', input_attr_alias, ', ', output_attr, ' 
                    ORDER BY match_rows DESC
                ) AS count_rows 
                GROUP BY ', input_attr_alias, '
            ) AS group_rows
        ) as attr_info 
        GROUP BY ', input_attr_alias, ';
    ');
    PREPARE stmt1 FROM @query;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
END
$$ DELIMITER ;

CALL 1R("genre", null, "classification", 1.0, null);

-- PROCEDURE discretize_range
DROP PROCEDURE IF EXISTS discretize_range;
DELIMITER $$
CREATE PROCEDURE discretize_range(
    input_attr varchar(50),
    output_attr varchar(50),
    acc_enough float,
    cond varchar(1024)
)
BEGIN
    DECLARE full_cond varchar(1044) DEFAULT '';
    IF cond IS NOT NULL THEN
      SET full_cond = CONCAT('WHERE ', cond);
    END IF;

    SET @query=CONCAT('
        SELECT 
          distinct(', input_attr, ') as uniq, 
          (
            SELECT 
              SUM(match_rows)/SUM(total_rows) AS overall_acc 
            FROM (
                SELECT 
                  lte, 
                  ', output_attr, ', 
                  match_rows, 
                  SUM(match_rows) AS total_rows, 
                  match_rows/SUM(match_rows) AS prob 
                FROM (
                    SELECT 
                      IF(', input_attr, ' <= uniq, 1, 0) AS lte, 
                      ', output_attr, ', 
                      COUNT(*) AS match_rows 
                    FROM games
                    ', full_cond, ' 
                    GROUP BY lte, ', output_attr, ' 
                    ORDER BY match_rows DESC
                ) AS count_rows 
                GROUP BY lte
            ) AS group_rows
          ) AS overall_acc,
          (
            SELECT 
              SUM(IF(prob < ', acc_enough, ', 1, 0)) as N
            FROM (
                SELECT 
                  lte, 
                  ', output_attr, ', 
                  match_rows, 
                  SUM(match_rows) AS total_rows, 
                  match_rows/SUM(match_rows) AS prob 
                FROM (
                    SELECT 
                      IF(', input_attr, ' <= uniq, 1, 0) AS lte, 
                      ', output_attr, ', 
                      COUNT(*) AS match_rows 
                    FROM games
                    ', full_cond, ' 
                    GROUP BY lte, ', output_attr, ' 
                    ORDER BY match_rows DESC
                ) AS count_rows 
                GROUP BY lte
            ) AS group_rows
          ) AS N,
          (
            SELECT 
              (SUM(match_rows)/SUM(total_rows))/SUM(IF(prob < ', acc_enough, ', 1, 0)) AS goodness
            FROM (
                SELECT 
                  lte, 
                  ', output_attr, ', 
                  match_rows, 
                  SUM(match_rows) AS total_rows, 
                  match_rows/SUM(match_rows) AS prob 
                FROM (
                    SELECT 
                      IF(', input_attr, ' <= uniq, 1, 0) AS lte, 
                      ', output_attr, ', 
                      COUNT(*) AS match_rows 
                    FROM games
                    ', full_cond, ' 
                    GROUP BY lte, ', output_attr, ' 
                    ORDER BY match_rows DESC
                ) AS count_rows 
                GROUP BY lte
            ) AS group_rows
          ) AS goodness
          FROM games
          ', full_cond, ' 
          ORDER BY goodness DESC, overall_acc DESC;
    ');
    PREPARE stmt1 FROM @query;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
END
$$ DELIMITER ;

CALL discretize_range("genre", "classification", 1.0, null);