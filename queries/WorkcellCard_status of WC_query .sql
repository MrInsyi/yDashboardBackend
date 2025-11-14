WITH latest_anomaly AS (
    SELECT DISTINCT ON (station_id)
        station_id,
        ms_flag,
        me_flag,
        mc_flag,
        mp_flag,
        bt_flag,
        qc_flag,
        anomaly_timestamp
    FROM jtc_anomaly_timeslot
    ORDER BY station_id, anomaly_timestamp DESC
),

station_status AS (
    SELECT 
        jw.id AS workcell_id,
        js.id AS station_id,
        js.is_running,
        
        -- TRUE if this station has no issues
        (la.ms_flag 
        AND la.me_flag 
        AND la.mc_flag 
        AND la.mp_flag 
        AND la.bt_flag 
        AND la.qc_flag) AS no_anomaly,

        -- TRUE if station has ANY anomaly
        NOT (la.ms_flag 
        AND la.me_flag 
        AND la.mc_flag 
        AND la.mp_flag 
        AND la.bt_flag 
        AND la.qc_flag) AS has_anomaly

    FROM jtc_workcell jw
    LEFT JOIN jtc_station js ON jw.id = js.workcell_id
    LEFT JOIN latest_anomaly la ON la.station_id = js.id
)

SELECT 
    workcell_id,

    CASE
        -- ERROR: any station not running AND has anomaly
        WHEN BOOL_OR(NOT is_running AND has_anomaly) 
            THEN 'ShutDown'

                -- ERROR: any station not running AND has anomaly
        WHEN BOOL_OR(is_running AND has_anomaly) 
            THEN 'Issue'

        -- RUNNING: any station running AND no anomalies anywhere
        WHEN BOOL_OR(is_running) 
             AND BOOL_AND(no_anomaly)
            THEN 'Running'

        -- IDLE: all not running AND no anomalies
        WHEN NOT BOOL_OR(is_running)
             AND BOOL_AND(no_anomaly)
            THEN 'Idle'

        ELSE 'Unknown'
    END AS workcell_status

FROM station_status
GROUP BY workcell_id
ORDER BY workcell_id;
