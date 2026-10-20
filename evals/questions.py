"""Ten-choice F1 evals. Evidence is kept in comments beside the questions."""

# Warehouse checks were run on 2026-10-20.
# SQL below is for manual verification; replace {project} with the configured project.

QUESTIONS = [
    # Answer key supplied by the user: Charles Leclerc.
    {
        'id': '01_handsomest',
        'category': 'unstructured',
        'question': 'Who is the handsomest F1 driver?',
        'choices': [
            'Charles Leclerc',
            'Lewis Hamilton',
            'Carlos Sainz',
            'Lando Norris',
            'Oscar Piastri',
            'George Russell',
            'Max Verstappen',
            'Fernando Alonso',
            'Pierre Gasly',
            'Nico Hulkenberg',
        ],
        'answer': 'Charles Leclerc',
    },

    # Verified against live race results and public race reporting.
    # The race report identifies Russell as the winner ahead of Verstappen and Norris.
    # https://www.formula1.com/en/latest/article/russell-storms-to-victory-in-singapore-as-mclaren-seal-teams.7cMITGtnc9fdxEaukmGVvI
    # Warehouse: Singapore: George Russell P1, Max Verstappen P2, Lando Norris P3.
    # Verification query: race_results.
    #
    # -- Replace {project} with the configured BigQuery project. Read-only authoring checks.
    # -- race_results: questions 02–05; starting grids attach through main Qualifying.
    # select
    #     m.meeting_name,
    #     d.full_name,
    #     r.position as finish_position,
    #     r.points,
    #     r.gap_to_leader,
    #     g.position as grid_position
    # from `{project}.f1.session_result` as r
    # join `{project}.f1.sessions` as s on r.session_key = s.session_key
    # join `{project}.f1.meetings` as m on s.meeting_key = m.meeting_key
    # join `{project}.f1.session_entries` as e
    #     on r.session_key = e.session_key and r.driver_number = e.driver_number
    # join `{project}.f1.drivers` as d on e.driver_id = d.driver_id
    # left join `{project}.f1.sessions` as q
    #     on m.meeting_key = q.meeting_key and q.session_name = 'Qualifying'
    # left join `{project}.f1.starting_grid` as g
    #     on q.session_key = g.session_key and e.driver_id = g.driver_id
    # where m.year = 2025
    #     and s.session_name = 'Race'
    #     and m.meeting_name in ('Singapore Grand Prix', 'British Grand Prix', 'Monaco Grand Prix')
    #     and r.position <= 4
    # order by m.meeting_name, r.position;
    {
        'id': '02_singapore_winner',
        'category': 'structured',
        'question': 'Who won the 2025 Singapore Grand Prix?',
        'choices': [
            'Charles Leclerc',
            'Lewis Hamilton',
            'Carlos Sainz',
            'Lando Norris',
            'Oscar Piastri',
            'George Russell',
            'Max Verstappen',
            'Fernando Alonso',
            'Pierre Gasly',
            'Nico Hulkenberg',
        ],
        'answer': 'George Russell',
    },

    # Uses the classified finishing gap, not the smallest gap during the race.
    # Eurosport race coverage lists Leclerc second, 3.131 seconds behind.
    # https://www.eurosport.fr/formule-1/grand-prix-de-monaco/2025/live-course_mtc1516039/live-commentary.shtml
    # Warehouse: Leclerc P2; gap_to_leader = 3.131.
    # Verification query: race_results.
    {
        'id': '03_monaco_margin',
        'category': 'structured',
        'question': 'How far behind winner Lando Norris did Charles Leclerc finish at the 2025 Monaco Grand Prix?',
        'choices': [
            '0.131 seconds',
            '1.131 seconds',
            '2.131 seconds',
            '3.131 seconds',
            '4.131 seconds',
            '5.131 seconds',
            '6.131 seconds',
            '7.131 seconds',
            '8.131 seconds',
            '9.131 seconds',
        ],
        'answer': '3.131 seconds',
    },

    # Net positions gained, not a count of on-track overtakes.
    # F1 describes his podium finish after starting nineteenth.
    # https://www.formula1.com/en/latest/article/driver-of-the-day-hulkenberg-gets-your-nod-after-epic-run-to-first-podium.74oX8MzusSsXnwIigGGlRT
    # Official F1 race analysis describes the progression from P19 to P3.
    # https://www.youtube.com/watch?v=MHP9xuQbm6g
    # Warehouse: British GP: grid_position 19; finish_position 3; 19 - 3 = 16.
    # Verification query: race_results.
    {
        'id': '04_hulkenberg_gain',
        'category': 'structured',
        'question': 'How many positions did Nico Hulkenberg gain from his starting-grid position to his classified finish in the 2025 British Grand Prix?',
        'choices': [
            '10',
            '11',
            '12',
            '13',
            '14',
            '15',
            '16',
            '17',
            '18',
            '19',
        ],
        'answer': '16',
    },

    # Only the Singapore Grand Prix race points, not cumulative season points.
    # The report records Norris third and Piastri fourth as McLaren secured the teams title.
    # https://www.formula1.com/en/latest/article/russell-storms-to-victory-in-singapore-as-mclaren-seal-teams.7cMITGtnc9fdxEaukmGVvI
    # The FIA constructors checkpoint records 27 points for McLaren at Singapore.
    # https://www.fia.com/sites/default/files/2025_18_sgp_f1_r0_timing_constructorschampionship_v01.pdf
    # Warehouse: Norris points = 15; Piastri points = 12; total = 27.
    # Verification query: race_results.
    {
        'id': '05_mclaren_points',
        'category': 'structured',
        'question': 'How many race points did Lando Norris and Oscar Piastri score between them at the 2025 Singapore Grand Prix?',
        'choices': [
            '18',
            '22',
            '24',
            '25',
            '26',
            '27',
            '30',
            '33',
            '40',
            '43',
        ],
        'answer': '27',
    },

    # Paraphrase of the driver’s account; not an independent causal claim.
    # Hulkenberg attributed the result to timely tyre choices and an error-free drive.
    # https://www.fia.com/news/f1-2025-british-grand-prix-post-race-press-conference-transcript
    # Warehouse: Nico HÜLKENBERG, passage 7 supports the answer.
    # Verification query: british_passages.
    #
    # -- british_passages: questions 06–08; include context around Piastri's request.
    # select
    #     t.source_url,
    #     p.position,
    #     p.speaker,
    #     p.text
    # from `{project}.f1.transcript_passages` as p
    # join `{project}.f1.transcripts` as t on p.document_id = t.document_id
    # where t.source_url like '%2025-british-grand-prix-post-race%'
    #     and p.position in (7, 63, 64, 65, 66, 67, 68)
    # order by p.position;
    {
        'id': '06_hulkenberg_explanation',
        'category': 'unstructured',
        'question': 'In his track interview after the 2025 British Grand Prix, what did Nico Hulkenberg credit for his podium?',
        'choices': [
            'Well-timed tyre decisions and avoiding mistakes in mixed conditions.',
            'A planned one-stop race on hard tyres without responding to rain.',
            'Staying on slick tyres throughout the wettest part of the race.',
            'A new engine delivering a decisive straight-line speed advantage.',
            'A late penalty promoting him after he crossed the line fourth.',
            'A teammate deliberately holding up Hamilton over the final stint.',
            'A red flag allowing him to recover a lap he had lost earlier.',
            'Starting on the front row and protecting that position all race.',
            'An early switch to full wet tyres that he kept until the finish.',
            'A setup change during the race that eliminated his tyre wear.',
        ],
        'answer': 'Well-timed tyre decisions and avoiding mistakes in mixed conditions.',
    },

    # Tests attribution and uncertainty rather than inventing a measured performance gain.
    # Norris emphasized his own preparation and could not quantify the suspension contribution.
    # https://www.fia.com/news/f1-2025-british-grand-prix-post-race-press-conference-transcript
    # Warehouse: Lando NORRIS, passage 63 supports the answer.
    # Verification query: british_passages.
    {
        'id': '07_norris_suspension',
        'category': 'unstructured',
        'question': 'When asked after the 2025 British Grand Prix about his revised front suspension, how did Lando Norris explain his recent improvement?',
        'choices': [
            'He attributed all of it to the suspension and none to his preparation.',
            'He said a direct comparison had proved a half-second gain per lap.',
            'He credited personal work more, while allowing that car changes helped.',
            'He said the suspension was slower and had already been removed.',
            'He attributed the improvement entirely to a more powerful engine.',
            'He said the changes mattered only in qualifying and never in races.',
            'He credited a new tyre compound unavailable to the other drivers.',
            'He said his driving was unchanged and weather explained everything.',
            'He credited team orders rather than improved pace or confidence.',
            'He said the revised suspension guaranteed victory in wet conditions.',
        ],
        'answer': 'He credited personal work more, while allowing that car changes helped.',
    },

    # Asks what the driver said, not whether the penalty was justified.
    # Piastri said he expected refusal and acknowledged that Norris had done nothing wrong.
    # https://www.fia.com/news/f1-2025-british-grand-prix-post-race-press-conference-transcript
    # Warehouse: Oscar PIASTRI, passages 65 and 68 support the answer.
    # Verification query: british_passages.
    {
        'id': '08_piastri_swap',
        'category': 'unstructured',
        'question': 'After the 2025 British Grand Prix, how did Oscar Piastri describe his request for McLaren to reverse his and Norris’s positions?',
        'choices': [
            'He said Norris had agreed to swap but the team overruled him.',
            'He said the stewards had ordered McLaren to swap the positions.',
            'He said the team had promised a swap before the race started.',
            'He said a swap was required because Norris had caused his penalty.',
            'He said he asked despite expecting no swap, and it would not be fair to Norris.',
            'He denied asking the team about changing their finishing order.',
            'He said the team had completed the swap before the final lap.',
            'He said Norris offered the position but he personally declined it.',
            'He said the swap was needed to correct a timing-system error.',
            'He said he wanted Hulkenberg moved behind both McLaren drivers.',
        ],
        'answer': 'He said he asked despite expecting no swap, and it would not be fair to Norris.',
    },

    # A pre-race expectation, not a claim that the rule actually improved the race.
    # F1’s explainer reports Verstappen anticipating strategic uncertainty and possible Safety Car
    # effects.
    # https://www.formula1.com/en/latest/article/explained-what-is-the-new-two-stop-rule-for-the-monaco-grand-prix-and-how.1qropbdmR05S3BqgYsHtpE.1qropbdmR05S3BqgYsHtpE
    # Warehouse: Max VERSTAPPEN, Thursday transcript passage 91 supports the answer.
    # Verification query: monaco_passage.
    #
    # -- monaco_passage: question 09.
    # select
    #     t.source_url,
    #     p.position,
    #     p.speaker,
    #     p.text
    # from `{project}.f1.transcript_passages` as p
    # join `{project}.f1.transcripts` as t on p.document_id = t.document_id
    # where t.source_url like '%2025-monaco-grand-prix-thursday%'
    #     and p.position = 91;
    {
        'id': '09_monaco_strategy',
        'category': 'unstructured',
        'question': 'Before the 2025 Monaco Grand Prix, what did Max Verstappen say the mandatory two-stop format might change?',
        'choices': [
            'It would guarantee frequent on-track overtaking at the front.',
            'It would remove the need to react to Safety Car timing.',
            'It would make qualifying irrelevant to the race result.',
            'It would require all teams to stop on identical prescribed laps.',
            'It would remove strategic uncertainty by fixing tyre choices.',
            'It would guarantee that the fastest qualifier won the race.',
            'It might add strategic gambling and uncertainty over when to stop.',
            'It would let drivers complete the race without changing tyres.',
            'It would prevent teams from attempting an undercut.',
            'It would make the race straightforward regardless of incidents.',
        ],
        'answer': 'It might add strategic gambling and uncertainty over when to stop.',
    },

    # An attempted strategy; success is not guaranteed.
    # F1’s glossary defines the earlier-stop strategy and the intended fresh-tyre advantage.
    # https://www.formula1.com/en/latest/article/f1-glossary-u-z.5JSlDsnyvYmbK0TCjTs7KB
    # Public strategy analysis explains gaining track position through an earlier stop and faster
    # laps.
    # https://www.f1-fansite.com/glossary/undercut/
    # Warehouse: Glossary section UNDERCUT confirms the earlier stop and fresh-tyre mechanism.
    # Verification query: undercut_passage.
    #
    # -- undercut_passage: question 10.
    # select
    #     g.source_url,
    #     p.section,
    #     p.text
    # from `{project}.f1.glossary_sections` as p
    # join `{project}.f1.glossary` as g on p.document_id = g.document_id
    # where lower(p.section) = 'undercut';
    {
        'id': '10_undercut',
        'category': 'unstructured',
        'question': 'In F1 race strategy, what is an undercut?',
        'choices': [
            'Staying out longer than a rival and trying to gain time before stopping.',
            'Pitting before a rival to gain time on fresher tyres and emerge ahead after their stop.',
            'Deliberately slowing before a pit stop to create a gap behind.',
            'Switching to a lower engine mode to extend the fuel range.',
            'Passing another car by using the inside line through a corner.',
            'Stopping both teammates together to give the second car priority.',
            'Choosing a shorter pit-lane route to reduce the stationary time.',
            'Giving a position back before the stewards impose a penalty.',
            'Starting from the pit lane to avoid a grid-position penalty.',
            'Running behind a rival to reduce drag on a long straight.',
        ],
        'answer': 'Pitting before a rival to gain time on fresher tyres and emerge ahead after their stop.',
    },

    # Added structured checks use the same race-result grain as questions 02–05.
    # Read-only verification query (run on 2026-10-20):
    # select
    #     m.meeting_name,
    #     d.full_name,
    #     r.position,
    #     r.points,
    #     r.gap_to_leader
    # from `{project}.f1.session_result` as r
    # join `{project}.f1.sessions` as s on r.session_key = s.session_key
    # join `{project}.f1.meetings` as m on s.meeting_key = m.meeting_key
    # join `{project}.f1.session_entries` as e
    #     on r.session_key = e.session_key and r.driver_number = e.driver_number
    # join `{project}.f1.drivers` as d on e.driver_id = d.driver_id
    # where m.year = 2025 and s.session_name = 'Race' and r.position <= 5;
    # Numeric differences and sums below are computed from these verified rows.

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-beats-verstappen-to-victory-in-dramatic-australian-gp-opener-amid.5rKGxQHJoDl1P8stMSHlIN
    # Warehouse/public classification: P1 Lando Norris.
    {
        'id': '11_australia_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Australian Grand Prix?',
        'choices': [
            'Lando Norris',
            'Charles Leclerc',
            'Oscar Piastri',
            'Fernando Alonso',
            'Kimi Antonelli',
            'Pierre Gasly',
            'Max Verstappen',
            'Franco Colapinto',
            'Isack Hadjar',
            'George Russell',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-beats-verstappen-to-victory-in-dramatic-australian-gp-opener-amid.5rKGxQHJoDl1P8stMSHlIN
    # Gaps to winner: Lando Norris 0s; Max Verstappen 0.895s; difference 0.895s.
    {
        'id': '12_australia_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Australian Grand Prix, how many seconds separated Lando Norris in P1 and Max Verstappen in P2?',
        'choices': [
            '0.895 seconds',
            '0.395 seconds',
            '0.795 seconds',
            '0.995 seconds',
            '1.395 seconds',
            '1.895 seconds',
            '2.895 seconds',
            '3.895 seconds',
            '5.895 seconds',
            '10.895 seconds',
        ],
        'answer': '0.895 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-beats-verstappen-to-victory-in-dramatic-australian-gp-opener-amid.5rKGxQHJoDl1P8stMSHlIN
    # Race points: George Russell 15; Kimi Antonelli 12. 15 + 12 = 27.
    {
        'id': '13_australia_points',
        'category': 'structured',
        'question': 'How many points did George Russell and Kimi Antonelli score between them in the 2025 Australian Grand Prix race, excluding any Sprint?',
        'choices': [
            '22',
            '23',
            '24',
            '25',
            '26',
            '27',
            '28',
            '29',
            '30',
            '31',
        ],
        'answer': '27',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-beats-norris-and-russell-to-victory-in-chinese-grand-prix-with.CpcwOmMwzcZGjM33Wkv8V
    # Warehouse/public classification: P2 Lando Norris.
    {
        'id': '14_china_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Chinese Grand Prix?',
        'choices': [
            'Lando Norris',
            'Isack Hadjar',
            'Oliver Bearman',
            'Gabriel Bortoleto',
            'Kimi Antonelli',
            'Carlos Sainz',
            'George Russell',
            'Charles Leclerc',
            'Lewis Hamilton',
            'Oscar Piastri',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-beats-norris-and-russell-to-victory-in-chinese-grand-prix-with.CpcwOmMwzcZGjM33Wkv8V
    # Gaps to winner: Lando Norris 9.748s; George Russell 11.097s; difference 1.349s.
    {
        'id': '15_china_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Chinese Grand Prix, how many seconds separated Lando Norris in P2 and George Russell in P3?',
        'choices': [
            '1.349 seconds',
            '0.349 seconds',
            '0.849 seconds',
            '1.249 seconds',
            '1.449 seconds',
            '1.849 seconds',
            '2.349 seconds',
            '3.349 seconds',
            '4.349 seconds',
            '6.349 seconds',
        ],
        'answer': '1.349 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-beats-norris-and-russell-to-victory-in-chinese-grand-prix-with.CpcwOmMwzcZGjM33Wkv8V
    # Race points: Oscar Piastri 25; Lando Norris 18. 25 - 18 = 7.
    {
        'id': '16_china_points',
        'category': 'structured',
        'question': 'How many more race points did Oscar Piastri score than Lando Norris at the 2025 Chinese Grand Prix, excluding any Sprint?',
        'choices': [
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
        ],
        'answer': '7',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-fourth-consecutive-japanese-gp-victory-ahead-of-norris.1MOpqos1ljTyhFILJKiHZD
    # Warehouse/public classification: P3 Oscar Piastri.
    {
        'id': '17_japan_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Japanese Grand Prix?',
        'choices': [
            'Oscar Piastri',
            'Fernando Alonso',
            'Gabriel Bortoleto',
            'Oliver Bearman',
            'Lance Stroll',
            'Jack Doohan',
            'Yuki Tsunoda',
            'Nico Hulkenberg',
            'Alexander Albon',
            'Isack Hadjar',
        ],
        'answer': 'Oscar Piastri',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-fourth-consecutive-japanese-gp-victory-ahead-of-norris.1MOpqos1ljTyhFILJKiHZD
    # Gaps to winner: Max Verstappen 0s; Lando Norris 1.423s; difference 1.423s.
    {
        'id': '18_japan_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Japanese Grand Prix, how many seconds separated Max Verstappen in P1 and Lando Norris in P2?',
        'choices': [
            '1.423 seconds',
            '0.423 seconds',
            '0.923 seconds',
            '1.323 seconds',
            '1.523 seconds',
            '1.923 seconds',
            '2.423 seconds',
            '3.423 seconds',
            '4.423 seconds',
            '6.423 seconds',
        ],
        'answer': '1.423 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-fourth-consecutive-japanese-gp-victory-ahead-of-norris.1MOpqos1ljTyhFILJKiHZD
    # Race points: Lando Norris 18; Oscar Piastri 15. 18 + 15 = 33.
    {
        'id': '19_japan_points',
        'category': 'structured',
        'question': 'How many points did Lando Norris and Oscar Piastri score between them in the 2025 Japanese Grand Prix race, excluding any Sprint?',
        'choices': [
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
        ],
        'answer': '33',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-storms-to-controlled-victory-in-bahrain-grand-prix-ahead-of-russell.47YQh0Ex2gkZcx58fRaRqJ
    # Warehouse/public classification: P1 Oscar Piastri.
    {
        'id': '20_bahrain_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Bahrain Grand Prix?',
        'choices': [
            'Oscar Piastri',
            'Max Verstappen',
            'Oliver Bearman',
            'Esteban Ocon',
            'Isack Hadjar',
            'Lance Stroll',
            'Lewis Hamilton',
            'Kimi Antonelli',
            'Franco Colapinto',
            'Alexander Albon',
        ],
        'answer': 'Oscar Piastri',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-storms-to-controlled-victory-in-bahrain-grand-prix-ahead-of-russell.47YQh0Ex2gkZcx58fRaRqJ
    # Gaps to winner: George Russell 15.499s; Lando Norris 16.273s; difference 0.774s.
    {
        'id': '21_bahrain_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Bahrain Grand Prix, how many seconds separated George Russell in P2 and Lando Norris in P3?',
        'choices': [
            '0.774 seconds',
            '0.274 seconds',
            '0.674 seconds',
            '0.874 seconds',
            '1.274 seconds',
            '1.774 seconds',
            '2.774 seconds',
            '3.774 seconds',
            '5.774 seconds',
            '10.774 seconds',
        ],
        'answer': '0.774 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-storms-to-controlled-victory-in-bahrain-grand-prix-ahead-of-russell.47YQh0Ex2gkZcx58fRaRqJ
    # Race points: Charles Leclerc 12; Lewis Hamilton 10. 12 - 10 = 2.
    {
        'id': '22_bahrain_points',
        'category': 'structured',
        'question': 'How many more race points did Charles Leclerc score than Lewis Hamilton at the 2025 Bahrain Grand Prix, excluding any Sprint?',
        'choices': [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
        ],
        'answer': '2',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-clinches-victory-in-saudi-arabia-from-verstappen-and-leclerc-as.1XBezBwUfLfjOayPSKNs41
    # Warehouse/public classification: P2 Max Verstappen.
    {
        'id': '23_saudi_arabia_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Saudi Arabian Grand Prix?',
        'choices': [
            'Max Verstappen',
            'George Russell',
            'Alexander Albon',
            'Carlos Sainz',
            'Charles Leclerc',
            'Pierre Gasly',
            'Gabriel Bortoleto',
            'Fernando Alonso',
            'Oscar Piastri',
            'Liam Lawson',
        ],
        'answer': 'Max Verstappen',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-clinches-victory-in-saudi-arabia-from-verstappen-and-leclerc-as.1XBezBwUfLfjOayPSKNs41
    # Gaps to winner: Oscar Piastri 0s; Max Verstappen 2.843s; difference 2.843s.
    {
        'id': '24_saudi_arabia_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Saudi Arabian Grand Prix, how many seconds separated Oscar Piastri in P1 and Max Verstappen in P2?',
        'choices': [
            '2.843 seconds',
            '0.843 seconds',
            '1.843 seconds',
            '2.343 seconds',
            '2.743 seconds',
            '2.943 seconds',
            '3.343 seconds',
            '3.843 seconds',
            '4.843 seconds',
            '5.843 seconds',
        ],
        'answer': '2.843 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-clinches-victory-in-saudi-arabia-from-verstappen-and-leclerc-as.1XBezBwUfLfjOayPSKNs41
    # Race points: Oscar Piastri 25; Lando Norris 12. 25 + 12 = 37.
    {
        'id': '25_saudi_arabia_points',
        'category': 'structured',
        'question': 'How many points did Oscar Piastri and Lando Norris score between them in the 2025 Saudi Arabian Grand Prix race, excluding any Sprint?',
        'choices': [
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
            '38',
            '39',
            '40',
            '41',
        ],
        'answer': '37',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-from-norris-and-russell-as-mclaren-seal-commanding-1-2-in-miami.6Vfaf5zEMOKmPHzHdkGdof
    # Warehouse/public classification: P3 George Russell.
    {
        'id': '26_miami_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Miami Grand Prix?',
        'choices': [
            'George Russell',
            'Franco Colapinto',
            'Kimi Antonelli',
            'Nico Hulkenberg',
            'Yuki Tsunoda',
            'Liam Lawson',
            'Oscar Piastri',
            'Max Verstappen',
            'Charles Leclerc',
            'Carlos Sainz',
        ],
        'answer': 'George Russell',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-from-norris-and-russell-as-mclaren-seal-commanding-1-2-in-miami.6Vfaf5zEMOKmPHzHdkGdof
    # Gaps to winner: Lando Norris 4.63s; George Russell 37.644s; difference 33.014s.
    {
        'id': '27_miami_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Miami Grand Prix, how many seconds separated Lando Norris in P2 and George Russell in P3?',
        'choices': [
            '33.014 seconds',
            '30.014 seconds',
            '31.014 seconds',
            '32.014 seconds',
            '32.514 seconds',
            '32.914 seconds',
            '33.114 seconds',
            '33.514 seconds',
            '34.014 seconds',
            '35.014 seconds',
        ],
        'answer': '33.014 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-from-norris-and-russell-as-mclaren-seal-commanding-1-2-in-miami.6Vfaf5zEMOKmPHzHdkGdof
    # Race points: Oscar Piastri 25; Lando Norris 18. 25 - 18 = 7.
    {
        'id': '28_miami_points',
        'category': 'structured',
        'question': 'How many more race points did Oscar Piastri score than Lando Norris at the 2025 Miami Grand Prix, excluding any Sprint?',
        'choices': [
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
        ],
        'answer': '7',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-storms-to-victory-in-thrilling-emilia-romagna-grand-prix-ahead-of.4YJG3CyQJdFzCI6tiBtqoU
    # Warehouse/public classification: P1 Max Verstappen.
    {
        'id': '29_emiliaromagna_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Emilia Romagna Grand Prix?',
        'choices': [
            'Max Verstappen',
            'Oliver Bearman',
            'Gabriel Bortoleto',
            'Pierre Gasly',
            'Kimi Antonelli',
            'Fernando Alonso',
            'Liam Lawson',
            'Franco Colapinto',
            'Lance Stroll',
            'Alexander Albon',
        ],
        'answer': 'Max Verstappen',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-storms-to-victory-in-thrilling-emilia-romagna-grand-prix-ahead-of.4YJG3CyQJdFzCI6tiBtqoU
    # Gaps to winner: Max Verstappen 0s; Lando Norris 6.109s; difference 6.109s.
    {
        'id': '30_emiliaromagna_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Emilia Romagna Grand Prix, how many seconds separated Max Verstappen in P1 and Lando Norris in P2?',
        'choices': [
            '6.109 seconds',
            '3.109 seconds',
            '4.109 seconds',
            '5.109 seconds',
            '5.609 seconds',
            '6.009 seconds',
            '6.209 seconds',
            '6.609 seconds',
            '7.109 seconds',
            '8.109 seconds',
        ],
        'answer': '6.109 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-storms-to-victory-in-thrilling-emilia-romagna-grand-prix-ahead-of.4YJG3CyQJdFzCI6tiBtqoU
    # Race points: Lando Norris 18; Oscar Piastri 15. 18 + 15 = 33.
    {
        'id': '31_emiliaromagna_points',
        'category': 'structured',
        'question': 'How many points did Lando Norris and Oscar Piastri score between them in the 2025 Emilia Romagna Grand Prix race, excluding any Sprint?',
        'choices': [
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
        ],
        'answer': '33',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-leads-mclaren-1-2-from-norris-in-spanish-gp-amid-late-race-drama-for.2t1WkW9NVeMzJbOIkpM8u8
    # Warehouse/public classification: P2 Lando Norris.
    {
        'id': '32_spain_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Spanish Grand Prix?',
        'choices': [
            'Lando Norris',
            'Lance Stroll',
            'Isack Hadjar',
            'Charles Leclerc',
            'Fernando Alonso',
            'Gabriel Bortoleto',
            'Oscar Piastri',
            'Kimi Antonelli',
            'Yuki Tsunoda',
            'Jack Doohan',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-leads-mclaren-1-2-from-norris-in-spanish-gp-amid-late-race-drama-for.2t1WkW9NVeMzJbOIkpM8u8
    # Gaps to winner: Lando Norris 2.471s; Charles Leclerc 10.455s; difference 7.984s.
    {
        'id': '33_spain_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Spanish Grand Prix, how many seconds separated Lando Norris in P2 and Charles Leclerc in P3?',
        'choices': [
            '7.984 seconds',
            '4.984 seconds',
            '5.984 seconds',
            '6.984 seconds',
            '7.484 seconds',
            '7.884 seconds',
            '8.084 seconds',
            '8.484 seconds',
            '8.984 seconds',
            '9.984 seconds',
        ],
        'answer': '7.984 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-leads-mclaren-1-2-from-norris-in-spanish-gp-amid-late-race-drama-for.2t1WkW9NVeMzJbOIkpM8u8
    # Race points: Oscar Piastri 25; Lando Norris 18. 25 - 18 = 7.
    {
        'id': '34_spain_points',
        'category': 'structured',
        'question': 'How many more race points did Oscar Piastri score than Lando Norris at the 2025 Spanish Grand Prix, excluding any Sprint?',
        'choices': [
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
        ],
        'answer': '7',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/russell-takes-solid-victory-as-piastri-and-norris-collide-late-on-in.2cri9oFCALqhfsbvpqDfBq
    # Warehouse/public classification: P3 Kimi Antonelli.
    {
        'id': '35_canada_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Canadian Grand Prix?',
        'choices': [
            'Kimi Antonelli',
            'Max Verstappen',
            'Nico Hulkenberg',
            'Charles Leclerc',
            'Isack Hadjar',
            'Lando Norris',
            'Oliver Bearman',
            'Liam Lawson',
            'Fernando Alonso',
            'Gabriel Bortoleto',
        ],
        'answer': 'Kimi Antonelli',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/russell-takes-solid-victory-as-piastri-and-norris-collide-late-on-in.2cri9oFCALqhfsbvpqDfBq
    # Gaps to winner: George Russell 0s; Max Verstappen 0.228s; difference 0.228s.
    {
        'id': '36_canada_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Canadian Grand Prix, how many seconds separated George Russell in P1 and Max Verstappen in P2?',
        'choices': [
            '0.228 seconds',
            '0.128 seconds',
            '0.328 seconds',
            '0.728 seconds',
            '1.228 seconds',
            '2.228 seconds',
            '3.228 seconds',
            '5.228 seconds',
            '10.228 seconds',
            '15.228 seconds',
        ],
        'answer': '0.228 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/russell-takes-solid-victory-as-piastri-and-norris-collide-late-on-in.2cri9oFCALqhfsbvpqDfBq
    # Race points: George Russell 25; Kimi Antonelli 15. 25 + 15 = 40.
    {
        'id': '37_canada_points',
        'category': 'structured',
        'question': 'How many points did George Russell and Kimi Antonelli score between them in the 2025 Canadian Grand Prix race, excluding any Sprint?',
        'choices': [
            '35',
            '36',
            '37',
            '38',
            '39',
            '40',
            '41',
            '42',
            '43',
            '44',
        ],
        'answer': '40',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-fends-off-piastri-for-austrian-gp-victory-in-thrilling-race-long.2CH71wVvRP1FaU8s04Tj7f
    # Warehouse/public classification: P1 Lando Norris.
    {
        'id': '38_austria_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Austrian Grand Prix?',
        'choices': [
            'Lando Norris',
            'Lewis Hamilton',
            'Nico Hulkenberg',
            'Kimi Antonelli',
            'Isack Hadjar',
            'Jack Doohan',
            'Oscar Piastri',
            'Lance Stroll',
            'Liam Lawson',
            'Pierre Gasly',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-fends-off-piastri-for-austrian-gp-victory-in-thrilling-race-long.2CH71wVvRP1FaU8s04Tj7f
    # Gaps to winner: Oscar Piastri 2.695s; Charles Leclerc 19.82s; difference 17.125s.
    {
        'id': '39_austria_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Austrian Grand Prix, how many seconds separated Oscar Piastri in P2 and Charles Leclerc in P3?',
        'choices': [
            '17.125 seconds',
            '14.125 seconds',
            '15.125 seconds',
            '16.125 seconds',
            '16.625 seconds',
            '17.025 seconds',
            '17.225 seconds',
            '17.625 seconds',
            '18.125 seconds',
            '19.125 seconds',
        ],
        'answer': '17.125 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-fends-off-piastri-for-austrian-gp-victory-in-thrilling-race-long.2CH71wVvRP1FaU8s04Tj7f
    # Race points: Charles Leclerc 15; Lewis Hamilton 12. 15 - 12 = 3.
    {
        'id': '40_austria_points',
        'category': 'structured',
        'question': 'How many more race points did Charles Leclerc score than Lewis Hamilton at the 2025 Austrian Grand Prix, excluding any Sprint?',
        'choices': [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
        ],
        'answer': '3',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-wet-dry-belgian-gp-after-late-pressure-from-title-rival-and.7QmPcUP90MvR5iX0w3j91
    # Warehouse/public classification: P2 Lando Norris.
    {
        'id': '41_belgium_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Belgian Grand Prix?',
        'choices': [
            'Lando Norris',
            'Oliver Bearman',
            'Fernando Alonso',
            'Oscar Piastri',
            'Pierre Gasly',
            'Liam Lawson',
            'Carlos Sainz',
            'George Russell',
            'Esteban Ocon',
            'Isack Hadjar',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-wet-dry-belgian-gp-after-late-pressure-from-title-rival-and.7QmPcUP90MvR5iX0w3j91
    # Gaps to winner: Oscar Piastri 0s; Lando Norris 3.415s; difference 3.415s.
    {
        'id': '42_belgium_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Belgian Grand Prix, how many seconds separated Oscar Piastri in P1 and Lando Norris in P2?',
        'choices': [
            '3.415 seconds',
            '0.415 seconds',
            '1.415 seconds',
            '2.415 seconds',
            '2.915 seconds',
            '3.315 seconds',
            '3.515 seconds',
            '3.915 seconds',
            '4.415 seconds',
            '5.415 seconds',
        ],
        'answer': '3.415 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-wet-dry-belgian-gp-after-late-pressure-from-title-rival-and.7QmPcUP90MvR5iX0w3j91
    # Race points: Oscar Piastri 25; Lando Norris 18. 25 + 18 = 43.
    {
        'id': '43_belgium_points',
        'category': 'structured',
        'question': 'How many points did Oscar Piastri and Lando Norris score between them in the 2025 Belgian Grand Prix race, excluding any Sprint?',
        'choices': [
            '38',
            '39',
            '40',
            '41',
            '42',
            '43',
            '44',
            '45',
            '46',
            '47',
        ],
        'answer': '43',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-holds-of-piastri-in-thrilling-battle-to-win-hungarian-grand-prix.3nguaFMU2JVNsT9QWopwzK
    # Warehouse/public classification: P3 George Russell.
    {
        'id': '44_hungary_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Hungarian Grand Prix?',
        'choices': [
            'George Russell',
            'Lewis Hamilton',
            'Esteban Ocon',
            'Franco Colapinto',
            'Oliver Bearman',
            'Lando Norris',
            'Gabriel Bortoleto',
            'Charles Leclerc',
            'Kimi Antonelli',
            'Max Verstappen',
        ],
        'answer': 'George Russell',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-holds-of-piastri-in-thrilling-battle-to-win-hungarian-grand-prix.3nguaFMU2JVNsT9QWopwzK
    # Gaps to winner: Oscar Piastri 0.698s; George Russell 21.916s; difference 21.218s.
    {
        'id': '45_hungary_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Hungarian Grand Prix, how many seconds separated Oscar Piastri in P2 and George Russell in P3?',
        'choices': [
            '21.218 seconds',
            '18.218 seconds',
            '19.218 seconds',
            '20.218 seconds',
            '20.718 seconds',
            '21.118 seconds',
            '21.318 seconds',
            '21.718 seconds',
            '22.218 seconds',
            '23.218 seconds',
        ],
        'answer': '21.218 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-holds-of-piastri-in-thrilling-battle-to-win-hungarian-grand-prix.3nguaFMU2JVNsT9QWopwzK
    # Race points: Lando Norris 25; Oscar Piastri 18. 25 - 18 = 7.
    {
        'id': '46_hungary_points',
        'category': 'structured',
        'question': 'How many more race points did Lando Norris score than Oscar Piastri at the 2025 Hungarian Grand Prix, excluding any Sprint?',
        'choices': [
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
        ],
        'answer': '7',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-as-norris-faces-late-race-retirement-in-dramatic-dutch-grand.5gVVQeQH0zjZk9hl6k6wvv
    # Warehouse/public classification: P1 Oscar Piastri.
    {
        'id': '47_netherlands_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Dutch Grand Prix?',
        'choices': [
            'Oscar Piastri',
            'Pierre Gasly',
            'George Russell',
            'Yuki Tsunoda',
            'Lance Stroll',
            'Isack Hadjar',
            'Lando Norris',
            'Liam Lawson',
            'Jack Doohan',
            'Max Verstappen',
        ],
        'answer': 'Oscar Piastri',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-as-norris-faces-late-race-retirement-in-dramatic-dutch-grand.5gVVQeQH0zjZk9hl6k6wvv
    # Gaps to winner: Oscar Piastri 0s; Max Verstappen 1.271s; difference 1.271s.
    {
        'id': '48_netherlands_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Dutch Grand Prix, how many seconds separated Oscar Piastri in P1 and Max Verstappen in P2?',
        'choices': [
            '1.271 seconds',
            '0.271 seconds',
            '0.771 seconds',
            '1.171 seconds',
            '1.371 seconds',
            '1.771 seconds',
            '2.271 seconds',
            '3.271 seconds',
            '4.271 seconds',
            '6.271 seconds',
        ],
        'answer': '1.271 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/piastri-wins-as-norris-faces-late-race-retirement-in-dramatic-dutch-grand.5gVVQeQH0zjZk9hl6k6wvv
    # Race points: Max Verstappen 18; Isack Hadjar 15. 18 + 15 = 33.
    {
        'id': '49_netherlands_points',
        'category': 'structured',
        'question': 'How many points did Max Verstappen and Isack Hadjar score between them in the 2025 Dutch Grand Prix race, excluding any Sprint?',
        'choices': [
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
        ],
        'answer': '33',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-charges-to-italian-gp-win-over-norris-and-piastri.6J7R9E9tzOI9Asy6HBmoVf
    # Warehouse/public classification: P2 Lando Norris.
    {
        'id': '50_italy_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Italian Grand Prix?',
        'choices': [
            'Lando Norris',
            'Kimi Antonelli',
            'Alexander Albon',
            'Jack Doohan',
            'George Russell',
            'Isack Hadjar',
            'Oscar Piastri',
            'Carlos Sainz',
            'Lance Stroll',
            'Nico Hulkenberg',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-charges-to-italian-gp-win-over-norris-and-piastri.6J7R9E9tzOI9Asy6HBmoVf
    # Gaps to winner: Lando Norris 19.207s; Oscar Piastri 21.351s; difference 2.144s.
    {
        'id': '51_italy_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Italian Grand Prix, how many seconds separated Lando Norris in P2 and Oscar Piastri in P3?',
        'choices': [
            '2.144 seconds',
            '0.144 seconds',
            '1.144 seconds',
            '1.644 seconds',
            '2.044 seconds',
            '2.244 seconds',
            '2.644 seconds',
            '3.144 seconds',
            '4.144 seconds',
            '5.144 seconds',
        ],
        'answer': '2.144 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-charges-to-italian-gp-win-over-norris-and-piastri.6J7R9E9tzOI9Asy6HBmoVf
    # Race points: Lando Norris 18; Oscar Piastri 15. 18 - 15 = 3.
    {
        'id': '52_italy_points',
        'category': 'structured',
        'question': 'How many more race points did Lando Norris score than Oscar Piastri at the 2025 Italian Grand Prix, excluding any Sprint?',
        'choices': [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
        ],
        'answer': '3',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-claims-dominant-azerbaijan-win-over-russell-and-sainz-after.gT4fbKTwpl3dI79nDmrHS
    # Warehouse/public classification: P3 Carlos Sainz.
    {
        'id': '53_azerbaijan_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Azerbaijan Grand Prix?',
        'choices': [
            'Carlos Sainz',
            'Isack Hadjar',
            'Yuki Tsunoda',
            'George Russell',
            'Kimi Antonelli',
            'Oliver Bearman',
            'Jack Doohan',
            'Nico Hulkenberg',
            'Fernando Alonso',
            'Lance Stroll',
        ],
        'answer': 'Carlos Sainz',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-claims-dominant-azerbaijan-win-over-russell-and-sainz-after.gT4fbKTwpl3dI79nDmrHS
    # Gaps to winner: Max Verstappen 0s; George Russell 14.609s; difference 14.609s.
    {
        'id': '54_azerbaijan_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Azerbaijan Grand Prix, how many seconds separated Max Verstappen in P1 and George Russell in P2?',
        'choices': [
            '14.609 seconds',
            '11.609 seconds',
            '12.609 seconds',
            '13.609 seconds',
            '14.109 seconds',
            '14.509 seconds',
            '14.709 seconds',
            '15.109 seconds',
            '15.609 seconds',
            '16.609 seconds',
        ],
        'answer': '14.609 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-claims-dominant-azerbaijan-win-over-russell-and-sainz-after.gT4fbKTwpl3dI79nDmrHS
    # Race points: George Russell 18; Kimi Antonelli 12. 18 + 12 = 30.
    {
        'id': '55_azerbaijan_points',
        'category': 'structured',
        'question': 'How many points did George Russell and Kimi Antonelli score between them in the 2025 Azerbaijan Grand Prix race, excluding any Sprint?',
        'choices': [
            '25',
            '26',
            '27',
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
        ],
        'answer': '30',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-commanding-victory-in-us-gp-ahead-of-norris-and-leclerc.2JcVVmPiQJsn7Js9LpOJJ
    # Warehouse/public classification: P1 Max Verstappen.
    {
        'id': '56_united_states_finish',
        'category': 'structured',
        'question': 'Who won the 2025 United States Grand Prix?',
        'choices': [
            'Max Verstappen',
            'Lando Norris',
            'Liam Lawson',
            'Yuki Tsunoda',
            'Fernando Alonso',
            'Jack Doohan',
            'Lewis Hamilton',
            'Carlos Sainz',
            'Oliver Bearman',
            'Charles Leclerc',
        ],
        'answer': 'Max Verstappen',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-commanding-victory-in-us-gp-ahead-of-norris-and-leclerc.2JcVVmPiQJsn7Js9LpOJJ
    # Gaps to winner: Lando Norris 7.959s; Charles Leclerc 15.373s; difference 7.414s.
    {
        'id': '57_united_states_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 United States Grand Prix, how many seconds separated Lando Norris in P2 and Charles Leclerc in P3?',
        'choices': [
            '7.414 seconds',
            '4.414 seconds',
            '5.414 seconds',
            '6.414 seconds',
            '6.914 seconds',
            '7.314 seconds',
            '7.514 seconds',
            '7.914 seconds',
            '8.414 seconds',
            '9.414 seconds',
        ],
        'answer': '7.414 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-surges-to-commanding-victory-in-us-gp-ahead-of-norris-and-leclerc.2JcVVmPiQJsn7Js9LpOJJ
    # Race points: Charles Leclerc 15; Lewis Hamilton 12. 15 - 12 = 3.
    {
        'id': '58_united_states_points',
        'category': 'structured',
        'question': 'How many more race points did Charles Leclerc score than Lewis Hamilton at the 2025 United States Grand Prix, excluding any Sprint?',
        'choices': [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
        ],
        'answer': '3',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-seals-commanding-win-in-action-packed-mexico-city-gp-to-take-world.5ztiajHhdtqagu0qQLx0vS
    # Warehouse/public classification: P2 Charles Leclerc.
    {
        'id': '59_mexico_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Mexico City Grand Prix?',
        'choices': [
            'Charles Leclerc',
            'Lance Stroll',
            'Pierre Gasly',
            'Oliver Bearman',
            'Kimi Antonelli',
            'Oscar Piastri',
            'Carlos Sainz',
            'Max Verstappen',
            'Liam Lawson',
            'Lando Norris',
        ],
        'answer': 'Charles Leclerc',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-seals-commanding-win-in-action-packed-mexico-city-gp-to-take-world.5ztiajHhdtqagu0qQLx0vS
    # Gaps to winner: Lando Norris 0s; Charles Leclerc 30.324s; difference 30.324s.
    {
        'id': '60_mexico_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Mexico City Grand Prix, how many seconds separated Lando Norris in P1 and Charles Leclerc in P2?',
        'choices': [
            '30.324 seconds',
            '27.324 seconds',
            '28.324 seconds',
            '29.324 seconds',
            '29.824 seconds',
            '30.224 seconds',
            '30.424 seconds',
            '30.824 seconds',
            '31.324 seconds',
            '32.324 seconds',
        ],
        'answer': '30.324 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-seals-commanding-win-in-action-packed-mexico-city-gp-to-take-world.5ztiajHhdtqagu0qQLx0vS
    # Race points: Lando Norris 25; Oscar Piastri 10. 25 + 10 = 35.
    {
        'id': '61_mexico_points',
        'category': 'structured',
        'question': 'How many points did Lando Norris and Oscar Piastri score between them in the 2025 Mexico City Grand Prix race, excluding any Sprint?',
        'choices': [
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
            '38',
            '39',
        ],
        'answer': '35',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-wins-thrilling-sao-paulo-gp-from-antonelli-as-verstappen-climbs-to.4T0Y5xGNn1MOVegzhGTqAx
    # Warehouse/public classification: P3 Max Verstappen.
    {
        'id': '62_brazil_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 São Paulo Grand Prix?',
        'choices': [
            'Max Verstappen',
            'Yuki Tsunoda',
            'Oscar Piastri',
            'Alexander Albon',
            'Nico Hulkenberg',
            'Esteban Ocon',
            'Gabriel Bortoleto',
            'Charles Leclerc',
            'Franco Colapinto',
            'Oliver Bearman',
        ],
        'answer': 'Max Verstappen',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-wins-thrilling-sao-paulo-gp-from-antonelli-as-verstappen-climbs-to.4T0Y5xGNn1MOVegzhGTqAx
    # Gaps to winner: Kimi Antonelli 10.388s; Max Verstappen 10.75s; difference 0.362s.
    {
        'id': '63_brazil_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 São Paulo Grand Prix, how many seconds separated Kimi Antonelli in P2 and Max Verstappen in P3?',
        'choices': [
            '0.362 seconds',
            '0.262 seconds',
            '0.462 seconds',
            '0.862 seconds',
            '1.362 seconds',
            '2.362 seconds',
            '3.362 seconds',
            '5.362 seconds',
            '10.362 seconds',
            '15.362 seconds',
        ],
        'answer': '0.362 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-wins-thrilling-sao-paulo-gp-from-antonelli-as-verstappen-climbs-to.4T0Y5xGNn1MOVegzhGTqAx
    # Race points: Kimi Antonelli 18; George Russell 12. 18 - 12 = 6.
    {
        'id': '64_brazil_points',
        'category': 'structured',
        'question': 'How many more race points did Kimi Antonelli score than George Russell at the 2025 São Paulo Grand Prix, excluding any Sprint?',
        'choices': [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
        ],
        'answer': '6',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-beats-norris-for-dominant-las-vegas-gp-victory-as-piastri.6u1Op0SO7YQa2bwJOq8DVI
    # Warehouse/public classification: P1 Max Verstappen.
    {
        'id': '65_las_vegas_finish',
        'category': 'structured',
        'question': 'Who won the 2025 Las Vegas Grand Prix?',
        'choices': [
            'Max Verstappen',
            'Jack Doohan',
            'Carlos Sainz',
            'Lewis Hamilton',
            'Lance Stroll',
            'George Russell',
            'Oliver Bearman',
            'Pierre Gasly',
            'Yuki Tsunoda',
            'Oscar Piastri',
        ],
        'answer': 'Max Verstappen',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-beats-norris-for-dominant-las-vegas-gp-victory-as-piastri.6u1Op0SO7YQa2bwJOq8DVI
    # Gaps to winner: Max Verstappen 0s; George Russell 23.546s; difference 23.546s.
    {
        'id': '66_las_vegas_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Las Vegas Grand Prix, how many seconds separated Max Verstappen in P1 and George Russell in P2?',
        'choices': [
            '23.546 seconds',
            '20.546 seconds',
            '21.546 seconds',
            '22.546 seconds',
            '23.046 seconds',
            '23.446 seconds',
            '23.646 seconds',
            '24.046 seconds',
            '24.546 seconds',
            '25.546 seconds',
        ],
        'answer': '23.546 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-beats-norris-for-dominant-las-vegas-gp-victory-as-piastri.6u1Op0SO7YQa2bwJOq8DVI
    # Race points: George Russell 18; Kimi Antonelli 15. 18 + 15 = 33.
    {
        'id': '67_las_vegas_points',
        'category': 'structured',
        'question': 'How many points did George Russell and Kimi Antonelli score between them in the 2025 Las Vegas Grand Prix race, excluding any Sprint?',
        'choices': [
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
        ],
        'answer': '33',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-wins-qatar-gp-as-title-battle-goes-to-abu-dhabi-with-piastri.5KlYT7q8OcrJ7AnMALjkxJ
    # Warehouse/public classification: P2 Oscar Piastri.
    {
        'id': '68_qatar_finish',
        'category': 'structured',
        'question': 'Who finished second in the 2025 Qatar Grand Prix?',
        'choices': [
            'Oscar Piastri',
            'Fernando Alonso',
            'Yuki Tsunoda',
            'Carlos Sainz',
            'Oliver Bearman',
            'Lando Norris',
            'Pierre Gasly',
            'Jack Doohan',
            'George Russell',
            'Isack Hadjar',
        ],
        'answer': 'Oscar Piastri',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-wins-qatar-gp-as-title-battle-goes-to-abu-dhabi-with-piastri.5KlYT7q8OcrJ7AnMALjkxJ
    # Gaps to winner: Oscar Piastri 7.995s; Carlos Sainz 22.665s; difference 14.670s.
    {
        'id': '69_qatar_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Qatar Grand Prix, how many seconds separated Oscar Piastri in P2 and Carlos Sainz in P3?',
        'choices': [
            '14.670 seconds',
            '11.670 seconds',
            '12.670 seconds',
            '13.670 seconds',
            '14.170 seconds',
            '14.570 seconds',
            '14.770 seconds',
            '15.170 seconds',
            '15.670 seconds',
            '16.670 seconds',
        ],
        'answer': '14.670 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/verstappen-wins-qatar-gp-as-title-battle-goes-to-abu-dhabi-with-piastri.5KlYT7q8OcrJ7AnMALjkxJ
    # Race points: Oscar Piastri 18; Lando Norris 12. 18 - 12 = 6.
    {
        'id': '70_qatar_points',
        'category': 'structured',
        'question': 'How many more race points did Oscar Piastri score than Lando Norris at the 2025 Qatar Grand Prix, excluding any Sprint?',
        'choices': [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
        ],
        'answer': '6',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-secures-maiden-f1-title-in-abu-dhabi-with-podium-finish-behind.EMJtmvRA0uzmzUC4MZgmw
    # Warehouse/public classification: P3 Lando Norris.
    {
        'id': '71_united_arab_emirates_finish',
        'category': 'structured',
        'question': 'Who finished third in the 2025 Abu Dhabi Grand Prix?',
        'choices': [
            'Lando Norris',
            'Isack Hadjar',
            'Kimi Antonelli',
            'Carlos Sainz',
            'Lance Stroll',
            'Jack Doohan',
            'Liam Lawson',
            'Max Verstappen',
            'Oscar Piastri',
            'Fernando Alonso',
        ],
        'answer': 'Lando Norris',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-secures-maiden-f1-title-in-abu-dhabi-with-podium-finish-behind.EMJtmvRA0uzmzUC4MZgmw
    # Gaps to winner: Max Verstappen 0s; Oscar Piastri 12.594s; difference 12.594s.
    {
        'id': '72_united_arab_emirates_gap',
        'category': 'structured',
        'question': 'In the final classification of the 2025 Abu Dhabi Grand Prix, how many seconds separated Max Verstappen in P1 and Oscar Piastri in P2?',
        'choices': [
            '12.594 seconds',
            '9.594 seconds',
            '10.594 seconds',
            '11.594 seconds',
            '12.094 seconds',
            '12.494 seconds',
            '12.694 seconds',
            '13.094 seconds',
            '13.594 seconds',
            '14.594 seconds',
        ],
        'answer': '12.594 seconds',
    },

    # Verified against BigQuery race results and the results table in this public race report:
    # https://www.formula1.com/en/latest/article/norris-secures-maiden-f1-title-in-abu-dhabi-with-podium-finish-behind.EMJtmvRA0uzmzUC4MZgmw
    # Race points: Oscar Piastri 18; Lando Norris 15. 18 + 15 = 33.
    {
        'id': '73_united_arab_emirates_points',
        'category': 'structured',
        'question': 'How many points did Oscar Piastri and Lando Norris score between them in the 2025 Abu Dhabi Grand Prix race, excluding any Sprint?',
        'choices': [
            '28',
            '29',
            '30',
            '31',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
        ],
        'answer': '33',
    },

    # Glossary verification: read the full matching section, not just an embedding result.
    # select
    #     g.source_url,
    #     p.section,
    #     p.text
    # from `{project}.f1.glossary_sections` as p
    # join `{project}.f1.glossary` as g on p.document_id = g.document_id
    # where p.section = '<SECTION NAMED BELOW>';
    # These public definitions are the same sources ingested into the warehouse.

    # Verified warehouse glossary section: UNDERSTEER; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-u-z.5JSlDsnyvYmbK0TCjTs7KB
    {
        'id': '74_understeer',
        'category': 'unstructured',
        'question': 'The front tyres lose grip and the car runs wider than the steering input suggests. What is this?',
        'choices': [
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Understeer',
    },

    # Verified warehouse glossary section: OVERSTEER; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-k-o.6g2hrWHA2pyxbXoe8FT9Db
    {
        'id': '75_oversteer',
        'category': 'unstructured',
        'question': 'The rear slides outward and the car rotates more than intended. What is this handling problem?',
        'choices': [
            'Oversteer',
            'Understeer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Oversteer',
    },

    # Verified warehouse glossary section: GRAINING; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-f-j.2g6grJVxT6dFCDpSmgoCQX
    {
        'id': '76_graining',
        'category': 'unstructured',
        'question': 'Rubber tears from the tread and sticks back onto it, leaving a rough surface. What is this called?',
        'choices': [
            'Graining',
            'Understeer',
            'Oversteer',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Graining',
    },

    # Verified warehouse glossary section: BLISTERING; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '77_blistering',
        'category': 'unstructured',
        'question': 'Internal tyre heat causes bubbles and chunks of tread to break away. What is this called?',
        'choices': [
            'Blistering',
            'Understeer',
            'Oversteer',
            'Graining',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Blistering',
    },

    # Verified warehouse glossary section: FLAT SPOT; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-f-j.2g6grJVxT6dFCDpSmgoCQX
    {
        'id': '78_flat_spot',
        'category': 'unstructured',
        'question': 'A tyre develops a flattened patch after sliding without rotating. What is the resulting damage called?',
        'choices': [
            'Flat spot',
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Flat spot',
    },

    # Verified warehouse glossary section: LOCK-UP; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-k-o.6g2hrWHA2pyxbXoe8FT9Db
    {
        'id': '79_lock_up',
        'category': 'unstructured',
        'question': 'Under heavy braking, a wheel stops rotating while the car keeps moving. What is happening?',
        'choices': [
            'Lock-up',
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Lock-up',
    },

    # Verified warehouse glossary section: AQUAPLANING; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '80_aquaplaning',
        'category': 'unstructured',
        'question': 'Standing water lifts the tyres away from the asphalt. What is this loss of contact called?',
        'choices': [
            'Aquaplaning',
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Dirty air',
            'Bottoming',
            'Marbles',
        ],
        'answer': 'Aquaplaning',
    },

    # Verified warehouse glossary section: DIRTY AIR; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '81_dirty_air',
        'category': 'unstructured',
        'question': 'A following car loses cornering downforce in a rival’s turbulent wake. What is that airflow called?',
        'choices': [
            'Dirty air',
            'Slipstream',
            'Downforce',
            'Drag',
            'DRS',
            'ERS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'Dirty air',
    },

    # Verified warehouse glossary section: SLIPSTREAM; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-p-t.GBhLQtpeu9b8LrK5VM0F1
    {
        'id': '82_slipstream',
        'category': 'unstructured',
        'question': 'Following another car on a straight reduces air resistance and increases speed. What is this benefit called?',
        'choices': [
            'Slipstream',
            'Downforce',
            'Drag',
            'Dirty air',
            'DRS',
            'ERS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'Slipstream',
    },

    # Verified warehouse glossary section: DOWNFORCE; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '83_downforce',
        'category': 'unstructured',
        'question': 'Which aerodynamic force presses an F1 car toward the road?',
        'choices': [
            'Downforce',
            'Slipstream',
            'Drag',
            'Dirty air',
            'DRS',
            'ERS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'Downforce',
    },

    # Verified warehouse glossary section: DRAG; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '84_drag',
        'category': 'unstructured',
        'question': 'Which aerodynamic force opposes a car’s forward motion?',
        'choices': [
            'Drag',
            'Slipstream',
            'Downforce',
            'Dirty air',
            'DRS',
            'ERS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'Drag',
    },

    # Verified warehouse glossary section: MARBLES; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-k-o.6g2hrWHA2pyxbXoe8FT9Db
    {
        'id': '85_marbles',
        'category': 'unstructured',
        'question': 'What do drivers call loose pieces of tyre rubber accumulated away from the racing line?',
        'choices': [
            'Marbles',
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Bottoming',
        ],
        'answer': 'Marbles',
    },

    # Verified warehouse glossary section: BOTTOMING; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '86_bottoming',
        'category': 'unstructured',
        'question': 'The car’s underside strikes the asphalt. What is this called?',
        'choices': [
            'Bottoming',
            'Understeer',
            'Oversteer',
            'Graining',
            'Blistering',
            'Flat spot',
            'Lock-up',
            'Aquaplaning',
            'Dirty air',
            'Marbles',
        ],
        'answer': 'Bottoming',
    },

    # Verified warehouse glossary section: DRS; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '87_drs',
        'category': 'unstructured',
        'question': 'In 2025, which system opened a rear-wing flap to reduce resistance in designated zones?',
        'choices': [
            'DRS',
            'Slipstream',
            'Downforce',
            'Drag',
            'Dirty air',
            'ERS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'DRS',
    },

    # Verified warehouse glossary section: ERS; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '88_ers',
        'category': 'unstructured',
        'question': 'Which system recovers energy, stores it electrically, and makes it available for deployment?',
        'choices': [
            'ERS',
            'Slipstream',
            'Downforce',
            'Drag',
            'Dirty air',
            'DRS',
            'Diffuser',
            'Ground effect',
            'Ride height',
            'Camber',
        ],
        'answer': 'ERS',
    },

    # Verified warehouse glossary section: PARC FERME; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-p-t.GBhLQtpeu9b8LrK5VM0F1
    {
        'id': '89_parc_ferme',
        'category': 'unstructured',
        'question': 'What is the name of the controlled area where FIA officials monitor cars and restrict work on them?',
        'choices': [
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'Out-lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Parc ferme',
    },

    # Verified warehouse glossary section: RED FLAG; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-p-t.GBhLQtpeu9b8LrK5VM0F1
    {
        'id': '90_red_flag',
        'category': 'unstructured',
        'question': 'Which flag signals a session suspension and instructs drivers to return slowly to the pits?',
        'choices': [
            'Red flag',
            'Yellow flag',
            'Blue flag',
            'Black flag',
            'Green flag',
            'White flag',
            'Chequered flag',
            'Black-and-white flag',
            'Black-and-orange flag',
            'Red-and-yellow flag',
        ],
        'answer': 'Red flag',
    },

    # Verified warehouse glossary section: YELLOW FLAG; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-u-z.5JSlDsnyvYmbK0TCjTs7KB
    {
        'id': '91_yellow_flag',
        'category': 'unstructured',
        'question': 'Which flag warns of a hazard ahead and prohibits overtaking?',
        'choices': [
            'Yellow flag',
            'Red flag',
            'Blue flag',
            'Black flag',
            'Green flag',
            'White flag',
            'Chequered flag',
            'Black-and-white flag',
            'Black-and-orange flag',
            'Red-and-yellow flag',
        ],
        'answer': 'Yellow flag',
    },

    # Verified warehouse glossary section: BLUE FLAG; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '92_blue_flag',
        'category': 'unstructured',
        'question': 'Which flag tells a backmarker during a race to allow a car about to lap them through?',
        'choices': [
            'Blue flag',
            'Red flag',
            'Yellow flag',
            'Black flag',
            'Green flag',
            'White flag',
            'Chequered flag',
            'Black-and-white flag',
            'Black-and-orange flag',
            'Red-and-yellow flag',
        ],
        'answer': 'Blue flag',
    },

    # Verified warehouse glossary section: BLACK FLAG; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '93_black_flag',
        'category': 'unstructured',
        'question': 'Which plain flag, displayed with a car number, tells that driver they are disqualified?',
        'choices': [
            'Black flag',
            'Red flag',
            'Yellow flag',
            'Blue flag',
            'Green flag',
            'White flag',
            'Chequered flag',
            'Black-and-white flag',
            'Black-and-orange flag',
            'Red-and-yellow flag',
        ],
        'answer': 'Black flag',
    },

    # Verified warehouse glossary section: SAFETY CAR; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-p-t.GBhLQtpeu9b8LrK5VM0F1
    {
        'id': '94_safety_car',
        'category': 'unstructured',
        'question': 'Which intervention uses a physical lead vehicle to gather the field at reduced speed during a hazard?',
        'choices': [
            'Safety Car',
            'Parc ferme',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'Out-lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Safety Car',
    },

    # Verified warehouse glossary section: VSC; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-u-z.5JSlDsnyvYmbK0TCjTs7KB
    {
        'id': '95_vsc',
        'category': 'unstructured',
        'question': 'Which intervention imposes a reduced-speed time delta without deploying a physical lead vehicle?',
        'choices': [
            'Virtual Safety Car (VSC)',
            'Parc ferme',
            'Safety Car',
            'Formation lap',
            'Out-lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Virtual Safety Car (VSC)',
    },

    # Verified warehouse glossary section: FORMATION LAP; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-f-j.2g6grJVxT6dFCDpSmgoCQX
    {
        'id': '96_formation_lap',
        'category': 'unstructured',
        'question': 'What is the lap immediately before a standing race start, used to prepare tyres and brakes, called?',
        'choices': [
            'Formation lap',
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Out-lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Formation lap',
    },

    # Verified warehouse glossary section: OUT-LAP; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-k-o.6g2hrWHA2pyxbXoe8FT9Db
    {
        'id': '97_out_lap',
        'category': 'unstructured',
        'question': 'What is the lap on which a driver leaves the pits called?',
        'choices': [
            'Out-lap',
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Out-lap',
    },

    # Verified warehouse glossary section: IN-LAP; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-f-j.2g6grJVxT6dFCDpSmgoCQX
    {
        'id': '98_in_lap',
        'category': 'unstructured',
        'question': 'What is the lap on which a driver returns to the pits called?',
        'choices': [
            'In-lap',
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'Out-lap',
            'Overcut',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'In-lap',
    },

    # Verified warehouse glossary section: OVERCUT; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-k-o.6g2hrWHA2pyxbXoe8FT9Db
    {
        'id': '99_overcut',
        'category': 'unstructured',
        'question': 'A driver stays out after a rival stops, trying to gain enough time before their own stop. Which strategy?',
        'choices': [
            'Overcut',
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'Out-lap',
            'In-lap',
            'Undercut',
            'Double stack',
            'Drive-through penalty',
        ],
        'answer': 'Overcut',
    },

    # Verified warehouse glossary section: DOUBLE STACK; public definition:
    # https://www.formula1.com/en/latest/article/f1-glossary-a-e.1MFONigMlQSbSQtpP7YCy2
    {
        'id': '100_double_stack',
        'category': 'unstructured',
        'question': 'What is it called when teammates pit one immediately after the other using the same crew?',
        'choices': [
            'Double stack',
            'Parc ferme',
            'Safety Car',
            'Virtual Safety Car (VSC)',
            'Formation lap',
            'Out-lap',
            'In-lap',
            'Overcut',
            'Undercut',
            'Drive-through penalty',
        ],
        'answer': 'Double stack',
    },

]
