# The new job of the data team is providing context to AI

Detailed presenter and editorial notes for the local-only PowerPoint deck. The deck and authenticated Gemini screenshots are ignored to keep deployment details out of Git.

These notes explain the current 18-slide deck: what each slide should communicate, why it is in the story, how to present it, and what supports its claims. They also distinguish verified implementation details from George’s account, estimates, metaphors, and proposed demo prompts. They are more detailed than the slides’ embedded speaker notes.

## Audience, argument, and pacing

The audience is business leaders. The sale is the experience of asking useful business questions and receiving answers grounded in the company’s facts and definitions. The desired decision is to give their own data team responsibility for providing that context to AI.

The argument is not that a company should build every component. It is that a company should own its business meaning, transformations, and context while using standard, often managed, components. Buying a warehouse or model is compatible with owning this solution. Outsourcing the understanding of the business to an opaque application is the dependency we want leaders to question.

The story moves from a business request, through evidence that this pattern already works, to a simple explanation of agents and databases, then to a concrete system and a live experience. The architecture diagrams are in the main presentation because they make the claim of practical buildability tangible. They should be walked through briskly, not taught as an engineering course. There is no appendix.

| Slide | Title | Duration | Clock |
| --- | --- | ---: | --- |
| 1 | The new job of the data team is providing context to AI | 0:30 | 0:00–0:30 |
| 2 | Business intelligence is dead. Long live context! | 2:00 | 0:30–2:30 |
| 3 | Everyone is building data agents | 2:30 | 2:30–5:00 |
| 4 | Even the AI labs | 2:30 | 5:00–7:30 |
| 5 | AI is a new consumer of the data stack | 1:30 | 7:30–9:00 |
| 6 | A brief history of data agents at Fivetran | 1:30 | 9:00–10:30 |
| 7 | A brief history of data agents at Fivetran | 2:00 | 10:30–12:30 |
| 8 | Agents and databases: Besties! | 0:30 | 12:30–13:00 |
| 9 | Agents | 1:00 | 13:00–14:00 |
| 10 | Databases | 1:00 | 14:00–15:00 |
| 11 | Is this...ontology? | 2:00 | 15:00–17:00 |
| 12 | DEMO: OpenF1 | 1:30 | 17:00–18:30 |
| 13 | The complete system, from API to agent | 2:30 | 18:30–21:00 |
| 14 | The same system, seen as tables | 2:00 | 21:00–23:00 |
| 15 | AGENTS schema | 2:30 | 23:00–25:30 |
| 16 | github.com/fivetran/f1-demo | 2:30 | 25:30–28:00 |
| 17 | Let's ask some questions! | 18:00 | 28:00–46:00 |
| 18 | Your data team should own your context | 4:00 | 46:00–50:00 |

Protect at least 15 minutes for the demo. If the opening runs long, compress the company examples and the diagram narration. Do not spend the demo allocation explaining embedding algorithms.

## Visual and source conventions

The deck uses Fivetran-inspired navy, blue, pale blue, warm neutral, and citron, with large typography and relatively little slide text. Internal brand guidelines informed the treatment. This is not an exact reproduction of the official template; the deck uses Arial for practical font availability.

Article images are cropped screenshots of the actual article headers. They establish provenance and recognition; they are not intended to make the audience read articles from the screen. The explanatory text next to them is our summary. The title portrait is George’s Slack profile photo, obtained through his authenticated account.

Public articles support what those companies describe about their own systems. They are not independent benchmarks or evidence that every organization will achieve the same results. Internal GitHub links below require Fivetran access. The demo repository is also private. Local code links identify the implementation behind the diagrams; mutable branch URLs describe the inspected version, not a permanently frozen release.

## Slide 1 — The new job of the data team is providing context to AI

**Purpose:** State the thesis immediately. This is a change in the data team’s customer and responsibility: AI becomes a consumer of the data team’s work, and context becomes an explicit deliverable.

**What is on screen:** A navy title slide with a large multiline title, George’s portrait, and the byline “George Fraser — CEO, Fivetran + dbt Labs.” The portrait makes this a personal account from someone who has built and used the system.

**Suggested narration:** “We have spent years making company data useful to people through business intelligence. Now we need to make it useful to AI. I want to show you what that experience looks like, what it takes to build, and why your data team should own it.”

Do not start with product names or the mechanics of the demo. The audience needs to understand the business promise before the implementation.

**Sources:** George’s supplied title, abstract, and byline; his Slack profile portrait; the brand references above. The title is the presentation’s thesis, not an externally established fact requiring a benchmark.

**Transition:** Give a concrete example of the interaction this new responsibility should enable.

## Slide 2 — Business intelligence is dead. Long live context!

**Purpose:** Sell the experience before the architecture. The executive asks for ideas, not a dashboard specification: “Give me your 3 best ideas for improving pipeline conversion.” The desired output is three useful suggestions grounded in accurate queries.

**What is on screen:** A deliberately provocative blue headline on a warm neutral background, the large sales question, and a cartoon of a generic AI assistant chat application without recognizable product branding. The closing question asks: “When your head of sales asks their AI assistant this question, can it give a good answer?”

**Suggested narration:** “To answer this well, an agent needs to know what we mean by pipeline, which stages we use, how we define conversion, which cohorts are comparable, and what has actually happened. It needs to investigate, propose explanations, and let us challenge them.”

Explain that the value is a conversation: ask, inspect, follow up, and decide. The reliable data and definitions behind BI remain necessary. “BI is dead” is a provocation about the interface and expectations, not a literal prediction that reports, dashboards, or the data stack vanish.

**Sources and limits:** The question and framing come from George’s abstract. This is an illustrative sales use case, not a demonstrated result from the F1 dataset. Do not imply the demo contains pipeline data or that the system has already produced three validated sales recommendations.

**Transition:** “Companies are already building versions of this.”

## Slide 3 — Everyone is building data agents

**Purpose:** Establish that this is an emerging practical pattern, not just a speculative vision. Different organizations call it research, knowledge AI, or a data agent. The common thread is company-specific context and access to existing information systems.

**What is on screen:** Three real article-header screenshots with concise conclusions beside them:

- Ramp Research: business context from dbt, Looker, and Snowflake.
- Stripe Kai: company tools and expertise, available where people work.
- DoorDash Vera: modeled data with business knowledge.

**Suggested narration:** Spend roughly 40 seconds on each example, then connect them. Ramp is the clearest bridge to the familiar analytics stack: metadata and domain-owner documentation help the agent understand the business. Stripe broadens the picture to organizational knowledge, tools, and skills. DoorDash emphasizes modeled data, curated knowledge, and making analytical work tractable for the agent.

The useful observation is that these companies assembled systems around their own knowledge. They did not get company understanding merely by purchasing access to a capable model.

**Sources:**

- [Ramp: Meet Ramp Research](https://builders.ramp.com/post/meet-ramp-research). Supports the use of analytics metadata and business context in a company research agent.
- [Stripe: Meet Stripe’s Knowledge AI platform](https://stripe.dev/blog/meet-stripes-knowledge-ai-platform). Supports the broader combination of company tools, knowledge, and domain skills across interfaces.
- [DoorDash: Inside Vera, DoorDash’s data agent](https://careersatdoordash.com/blog/inside-vera-doordashs-data-agent/). Supports the role of modeled data, business knowledge, and evaluation in a company-built analytical agent.

**Claim boundary:** These are related systems, not identical architectures. In particular, Stripe is broader than warehouse analytics. Do not say every example exclusively uses a warehouse or implements AGENTS Schema. No adoption, productivity, or accuracy statistics are needed for the argument.

**Transition:** “Even the companies that build the models have to do this work.”

## Slide 4 — Even the AI labs

**Purpose:** Defuse the assumption that a sufficiently powerful model automatically understands a business. The model builders themselves invest in context and data foundations.

**What is on screen:** OpenAI and Anthropic article screenshots on navy. The summaries emphasize warehouse queries enriched by company context, and data foundations with shared definitions and skills.

**Suggested narration:** OpenAI’s account describes multiple sources of context, including table usage, human annotation, code, institutional knowledge, memory, and runtime context. Anthropic’s account emphasizes trusted datasets, semantic definitions, skills, and validation. The model is one part of the system; company understanding has to be supplied and maintained.

The implication for leaders is encouraging: they do not need to train a foundation model to make progress. They need a capable model with access to the right facts, definitions, and tools.

**Sources:**

- [OpenAI: Inside our in-house data agent](https://openai.com/index/inside-our-in-house-data-agent/).
- [Anthropic: How Anthropic enables self-service data analytics with Claude](https://claude.com/resources/articles/how-anthropic-enables-self-service-data-analytics-with-claude).

**Claim boundary:** These articles support the importance of context, not a claim that either organization uses this demo’s exact schema or architecture. Anthropic’s discussion of semantic structure does not establish an AGENTS Schema implementation.

**Transition:** Extract one simple architectural lesson from all five examples.

## Slide 5 — AI is a new consumer of the data stack

**Purpose:** Reframe AI as a use for existing data investments. This is the central architectural synthesis of the prior-art section.

**What is on screen:** Business systems flow into a warehouse or lakehouse. That shared foundation branches to business intelligence and AI agents. The footer asks “How do we help AI agents navigate the data warehouse?”

**Suggested narration:** “You already bring business data together, resolve identities, define useful models, and decide what metrics mean. AI needs that same work. The data team now has another consumer.”

The diagram intentionally omits platform details. Leaders should recognize a familiar asset, then see the new opportunity. A model can change without requiring the company to surrender ownership of its definitions and transformations.

**Sources:** This is our synthesis of the Ramp, DoorDash, OpenAI, and Anthropic articles linked on slides 3–4. It is not a diagram copied from any one company.

**Claim boundary:** Other tools, operational systems, and documents can also matter. The slide does not assert that every interaction must pass through a warehouse. Nor does reuse eliminate the need to improve poor-quality data or ambiguous definitions.

**Transition:** “Here is how that evolution has played out inside Fivetran.”

## Slide 6 — A brief history of data agents at Fivetran

**Purpose:** Make the story personal and credible. Fivetran has experience with this problem, including an earlier implementation with more separately operated components.

**What is on screen:** The subtitle reads “The first version of 'Fivetran Chat', 2025”. Slack connects to a custom agent, with a graph database, BigQuery, and separate vector index behind it at the same architectural layer. The concluding line is “The experience was valuable. The architecture had more moving parts.”

**Suggested narration:** Describe the early goal: let people ask questions about company information from the place where they already worked. The useful experience came first; the supporting architecture evolved. Keep this at the level of operating a system, rather than explaining graph traversal or vector similarity.

**Sources:**

- [Archived fivetran_chat frontend](https://github.com/fivetran/cto-research/tree/main/fivetran_chat) and [early README](https://github.com/fivetran/cto-research/blob/main/fivetran_chat/fivetran_chat_readme.md).
- [Earlier fivetran-ai backend](https://github.com/fivetran/cto-research/tree/main/fivetran-ai).
- [Vector search service implementation](https://github.com/fivetran/cto-research/blob/main/fivetran-ai/core/src/core/vector_search_service.py), which provides concrete evidence of a separate Chroma store.
- George’s account supplies the early graph-database and BigQuery components and the overall historical framing.

**Claim boundary:** The graph engine was not independently established from the inspected evidence. Do not name a particular engine or present the diagram as an exhaustive deployment inventory at one exact date.

**Transition:** Contrast the separately assembled early system with shared data and context serving several workflows.

## Slide 7 — A brief history of data agents at Fivetran

**Purpose:** Show why company context is infrastructure rather than a feature tied to a single chatbot. The same investment can support conversational analytics and automated support.

**What is on screen:** The subtitle reads “Today: database-native AI”. Slack, Claude, and a support agent connect through MCP to a data warehouse containing structured data, unstructured data, embeddings and search indexes attached to unstructured data, and AGENTS schema. Looker supplies metadata to AGENTS schema. The emphasis is reuse.

**Suggested narration:** “We should not need to teach every new application what our business means from scratch. If the data and context are shared, multiple agents and interfaces can use them.” Explain that warehouse search capabilities reduce the need for a separate retrieval system, while context remains useful across frontends.

**Sources:**

- [Current fivetran_chat](https://github.com/fivetran/engineering/tree/main/fivetran_ai/fivetran_chat).
- [Fivetran Context instructions](https://github.com/fivetran/engineering/blob/main/fivetran_ai/fivetran_context/Skill.md), including the Claude-facing context workflow.
- [MCP documentation](https://github.com/fivetran/engineering/blob/main/fivetran_ai/mcp/README.md).
- [BigQuery context and retrieval guidance](https://github.com/fivetran/engineering/blob/main/fivetran_ai/toolkit/indexing/src/indexing/agents_schema_writer/resources/fivetran_connections_root_big_query.md).
- George’s account of the current architecture, support-agent use case, and Looker metadata feeding AGENTS schema.

**Claim boundary:** Claude is an additional interface, not evidence that the Slack backend was replaced by Claude. The inspected current backend describes its own OpenAI Agents SDK implementation and persistent memory. “No separate graph database” comes from George’s account; it does not mean there are no relationships or graph-like concepts in the data. Internal migration plans are not proof that every proposed change is deployed.

**Transition:** Explain why this division of responsibility works so well.

## Slide 8 — Agents and databases: Besties!

**Purpose:** Introduce a memorable pairing before unpacking each side. This is intentionally its own short slide, followed by separate agents and databases slides.

**What is on screen:** “Agents and databases: Besties!” above two cartoon characters high-fiving: an AI robot on the left and a database cylinder on the right. Phrases around the agent describe interpreting open-ended questions, connecting ideas across sources, and explaining findings in plain language. Phrases around the database describe storing facts over time, making relationships explicit, and running repeatable calculations. The slide contains only the title, characters, labels, and strengths.

**Suggested narration:** “Agents and databases are besties. The things agents are good at and the things databases are good at fit together remarkably well.” Pause long enough for the phrase to land, then move on.

**Sources and limits:** This is George’s explanatory metaphor. Databases can compute, and agents can use persistent external memory; the comparison highlights strengths rather than defining strict technical limits.

**Transition:** “First, the agent.”

## Slide 9 — Agents

**Purpose:** Explain the agent’s strengths through specific tasks it can perform.

**What is on screen:** The same cartoon agent character from slide 8, isolated on the left. A checklist with green checks identifies five strengths:

- Interprets questions in everyday language.
- Plans multi-step investigations.
- Uses tools to query data and find documents.
- Connects evidence across sources.
- Explains findings in plain language.

**Suggested narration:** “An agent can take a business question, plan an investigation, use tools to find the relevant data, and explain the findings. That gives us a conversational way to work with our company’s information.” Walk through the checklist briefly before moving to databases.

**Sources:** The company data-agent examples on slides 3–4 provide the context for these capabilities. The illustration isolates the agent character from slide 8 using the built-in imagegen tool.

**Transition:** “Now put that next to a database.”

## Slide 10 — Databases

**Purpose:** Explain the database’s complementary strengths through specific tasks it performs.

**What is on screen:** The same cartoon database character from slide 8, isolated on the left. A checklist with green checks identifies five strengths:

- Stores and retrieves persistent facts.
- Makes relationships between records explicit.
- Joins and aggregates large datasets.
- Runs precise, repeatable calculations.
- Controls access through permissions.

The layout matches slide 9, using the deck’s navy background and white text. There is no bottom line.

**Suggested narration:** “The database keeps our facts, connects related records, and executes the calculations. We can also control who can access the data. These capabilities complement the agent’s ability to investigate a question and explain what it finds.”

An accessible example is counting customers: the database executes the calculation, while the organization defines what counts as a customer. That definition connects to the next slide.

**Sources:** The demo’s models and catalog illustrate the database capabilities. The illustration isolates the database character from slide 8 using the built-in imagegen tool.

**Transition:** “So where do we put that business meaning?”

## Slide 11 — AGENTS schema

**Purpose:** Introduce the five-table context interface after the agent and database strengths.

**What is on screen:** The title “AGENTS schema”, a table-name-only diagram, and the clickable URL `github.com/dbt-labs/agents_schema`. ROOT appears above TABLES. DIMENSIONS, MEASURES, and JOINS appear beneath TABLES. Dashed lines indicate navigation and metadata references. The example-row table and bottom line are removed.

**Suggested narration:** “ROOT is the starting point. TABLES tells the agent what tables exist and what each row means. DIMENSIONS describes their columns, MEASURES defines calculations, and JOINS describes how tables connect.”

**Sources:** [AGENTS Schema repository](https://github.com/dbt-labs/agents_schema), [Catalog](../agents/catalog.yml), [ROOT guidance](../agents/ROOT.md), and [seed schemas](../dbt/seeds/agents/schema.yml).

**Claim boundary:** Dashed lines are logical catalog references, not physical foreign keys. JOINS references source and target tables; the diagram combines those two references into one connection for readability. ROOT is the core open contract, while the four other tables are this demo’s dimensional extension. The metadata describes finished tables for readers and agents.

**Transition:** “Does putting meanings and relationships in tables make this an ontology?”

## Slide 12 — Is this...ontology?

**Purpose:** Make business context feel small, understandable, and ownable. This is the deliberate but restrained contrast with proprietary ontology platforms.

**What is on screen:** A full-slide rendition of the “Is this a pigeon?” meme with the question “Is this...ontology?” floating over the bottom of the image. A floating database table replaces the butterfly. The original comparison text and bottom line are removed. The image was generated using the built-in imagegen tool.

**Suggested narration:** “You need a way to tell the agent what things mean, how they connect, and how to calculate useful measures. For this analytical workflow, that can be a very simple interface in the database you already use.”

Explain the essential idea, not every column: a discoverable starting point directs an agent to readable context. In this demo, that context includes tables, dimensions, measures, and joins. The team can inspect it, version it, and use it from different clients.

**Sources:**

- [AGENTS Schema overview](https://www.opendatainfrastructure.com/agents-schema).
- [AGENTS Schema repository](https://github.com/dbt-labs/agents_schema) and the [specification revision used by this project](https://github.com/dbt-labs/agents_schema/blob/a0bc90498302c8abb15a5e98a54c8c94df5a52f8/SPEC.md).
- [Palantir Ontology overview](https://www.palantir.com/docs/foundry/ontology/overview/) and [architecture documentation](https://www.palantir.com/docs/foundry/architecture-center/ontology-system).
- The demo’s [ROOT guidance](../agents/ROOT.md) and [catalog](../agents/catalog.yml).

**Claim boundary:** Palantir’s Ontology includes operational capabilities, actions, security, and applications beyond this thin context interface. We are not claiming five tables replace that entire platform. We are questioning whether that full platform is required to provide context for the experience being demonstrated. Also, `ROOT(provider, key, content)` is the core contract; the four other tables are this project’s dimensional extension, not four universally mandatory tables in the open specification.

**Transition:** “Let’s make this concrete with a dataset we can show openly.”

## Slide 13 — DEMO: OpenF1

**Purpose:** Introduce a rich but approachable demo domain, and state the portability argument before showing the implementation.

**What is on screen:** The title “DEMO: OpenF1” over a full-slide race image. Two square liquid-glass panels with translucent centers and reflective edges identify structured data (“Races, laps, telemetry”) and unstructured data (“Rules and glossary”, “Press conferences”). There is no other slide content. The background is an AI-generated illustrative race scene, not a photograph of a specified actual event.

**Suggested narration:** “Racing gives us numerical facts, specialized language, and people explaining what happened. A useful agent needs to work across all three. That is similar to combining sales records, business definitions, and customer conversations.”

Race data answers what happened and supports comparisons. Rules and glossary explain terms and constraints. Press conferences provide attributed narrative evidence. The cross-domain follow-up is the interesting part of the demo, not simply producing a leaderboard.

**Sources:** [OpenF1](https://openf1.org/), the [document manifest](../connectors/documents/manifest.json), [catalog](../agents/catalog.yml), [ROOT guidance](../agents/ROOT.md), and [example questions](../agents/QUESTIONS.md).

**Claim boundary:** Racing coverage includes 2025 and completed 2026 races; documents remain scoped to 2025. Use 2025 for questions combining racing and documents. Press conferences are not transcribed team radio. A current glossary page is not automatically authority for a historical regulation.

The architecture is portable; the exact implementation is not vendor-independent SQL. BigQuery’s embedding, hybrid-search, and serving APIs are specific choices. A move to Snowflake, Databricks, Fabric, or DuckDB on Iceberg would change dialects, search mechanisms, and integration code. The claim is that no particular vendor’s proprietary ontology platform is essential to the pattern.

**Transition:** “Here is everything we assembled to make that conversation work.”

## Slide 14 — The complete system, from API to agent

**Purpose:** Show the whole workflow, including the less glamorous parts, while making clear that standard components and declarative definitions make it manageable. This is the principal API-to-agent diagram the presentation needs.

**What is on screen:** Sources feed two Fivetran connectors, which load source tables. dbt defines normalized models, context publication, and incremental document passages with embeddings and indexes. At the experience end, the F1 Analyst data agent contains a block labeled only “System prompt”. The “Live SQL + search” caption, Gemini Enterprise, and the two bottom lines are removed.

**Suggested narration:** Walk left to right once:

1. OpenF1 endpoints and document sources enter through two connectors.
2. Source tables preserve the ingested data.
3. dbt defines useful models, searchable document passages, and the metadata an agent needs to understand them.
4. The database computes embeddings and maintains the index in the background.
5. The analyst uses the resulting data and context with system instructions that guide queries and answers.

The point is not that there is no engineering here. There are several responsibilities, but they are expressible in familiar components and code. Declarative definitions replace a separately hand-operated embedding workflow. Keep embeddings to one sentence unless asked: they enable meaning-based retrieval alongside lexical search.

**Implementation behind the picture:**

- The [OpenF1 connector](../connectors/openf1/connector.py) and [documents connector](../connectors/documents/connector.py) own ingestion.
- [Normalized models](../dbt/models/openf1/) define the structured data.
- The [incremental search model](../dbt/models/search/document_passages_search.sql) updates changed passages and removes obsolete ones.
- [Search hooks](../dbt/macros/document_search.sql) declare the managed embedding column and hybrid index.
- [AGENTS publication](../dbt/macros/publish_agents.sql) publishes the five metadata tables after the complete seed batch succeeds.
- [Agent configuration](../scripts/configure_data_agent.py) provisions the agent using the catalog.
- The [pipeline runner](../scripts/run_pipeline.py) can orchestrate ingestion and dbt work.

**Important diagram simplifications:** The agent queries the finished numerical tables as well as document search; data does not become accessible only by passing through AGENTS. AGENTS supplies meaning. Provisioning reads the catalog into an agent-context snapshot, while subsequent data queries are live. The diagram combines these two kinds of access for readability.

The demonstrated Gemini route uses A2A to the managed data agent, not MCP. MCP is a viable alternative interface for other clients, and is part of the earlier Fivetran architecture discussion; it is not secretly inserted into the live demo path.

**Claim boundary:** “dbt defines the workflow” refers to the data transformations, search definitions, and metadata publication. Connectors, account setup, and agent provisioning also exist outside dbt. Managed maintenance does not mean no maintenance of business definitions, source changes, credentials, or infrastructure. No recurring refresh schedule is configured in this demo. Build completion also does not prove asynchronous embeddings and index maintenance have finished. Hybrid search is a Preview capability in this implementation.

**Transition:** “That is the flow of work. Here is the same system as data.”

## Slide 15 — SQL, hybrid search, and reranking

**Purpose:** Show a concrete query combining structured racing metadata with unstructured document retrieval and explicit reranking.

**What is on screen:** Executable BigQuery SQL searches post-race transcripts for tyre degradation with `AI.SEARCH`, using `HYBRID` mode for vector and keyword search. It joins `f1.meetings` to select 2025, scores retrieved passages using `AI.GENERATE_DOUBLE`, and returns the five highest non-null scores. The relevant lines are highlighted.

**Suggested narration:** “The same SQL query combines precise filters and joins with semantic and keyword retrieval. After retrieving candidates, we ask a model to judge their relevance and reorder the results.”

**Query:** [hybrid-query.sql](hybrid-query.sql). Run in project `__F1_GCP_PROJECT__`, location US; the shortened table and connection names use that default project. The complete query was dry-run validated and executed on 2026-10-12, returning five ranked passages.

**Sources:** [AI.SEARCH](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-ai-search), [AI.GENERATE_DOUBLE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-ai-generate-double), and the [project search definition](../dbt/macros/document_search.sql).

**Claim boundary:** The relevance score is a model-generated judgment, not calibrated confidence or a dedicated cross-encoder. Failed scores are NULL and excluded; inspect the function status to diagnose failures. Hybrid retrieval selects candidates before the year join, so restrictive postfilters can reduce the final count. Retrieval does not prove exhaustive coverage. Hybrid search and scalar model functions are Preview.

---

## Slide 16 — The same system, seen as tables

**Purpose:** Ground the workflow in ordinary relational structures. This is where the audience should see that the system contains recognizable data assets, rather than an opaque AI-specific store.

**What is on screen:** Three framed crops of actual Mermaid-rendered ER diagrams, labeled SOURCE, NORMALIZED, and AGENTS. The source crop focuses on `f1_openf1.drivers` and related endpoint tables; source drivers are entries within a session. The normalized crop focuses on `f1.session_entries` and related facts. The AGENTS crop shows `TABLES`, `DIMENSIONS`, `MEASURES`, and `JOINS`, with the connection to `ROOT` continuing beyond the left edge. Table names and crow’s feet are visible; column detail is omitted. The full diagrams, Mermaid source, and exact crops are retained in [assets/schema/](assets/schema/).

**Suggested narration:** “We keep the source data, build useful tables from it, and put instructions for readers next to the finished tables.” Point to one identity relationship and one document path. Do not enumerate every table.

A useful example is the driver: a number identifies an entry within a session, not a person forever. Modeling that distinction makes cross-race questions more reliable. The catalog then explains the distinction to the agent.

**Sources:** [Normalized models](../dbt/models/openf1/), especially [session entries](../dbt/models/openf1/session_entries.sql); the [catalog](../agents/catalog.yml); [ingestion schema documentation](../SCHEMA.md); [BI Engine configuration](../infra/agents_bi_engine.sql); and the current [project guide](../AGENTS.md). The [proposed model](../PROPOSED_MODEL.md) provides design background, but current implementation and operational guidance take precedence over historical proposal text.

**Claim boundary:** These are literal crops of larger rendered schemas. The source render also contains the document-source tables, outside this crop. The normalized render includes geography, identities, sessions, and document search beyond the crop. Crow’s feet indicate logical data relationships, not enforced BigQuery foreign keys. A result is optional and at most one per session entry. Source `drivers` are session entries, while normalized `drivers` are canonical people. Dashed lines in AGENTS indicate catalog/navigation references, not data joins. The three panels do not depict transformation lineage. The catalog exposes 24 finished OpenF1 tables and one document-search table, excluding internal identity helpers and ingestion schemas.

The 1 GiB BI Engine reservation prefers exactly the five AGENTS metadata tables. Do not imply that the telemetry tables or search index are accelerated by it. Actual acceleration requires query-job evidence; the configuration alone is not proof.

**Transition:** “Here is what building this system involved.”

## Slide 17 — github.com/fivetran/f1-demo

**What is on screen:** The linked repository URL `github.com/fivetran/f1-demo`, the estimate “~3 hours human steering + ~10 hours agent time”, and a four-row table with product logos. dbt and Gemini Enterprise use direct PNG images for reliable Keynote import:

| Component | Product |
| --- | --- |
| Connectors | Fivetran |
| Transformation | dbt |
| Database | BigQuery |
| Agent | Gemini Enterprise |

There is no additional slide text.

**Sources:** George supplied the updated time estimate. The project lives at [fivetran/f1-demo](https://github.com/fivetran/f1-demo). Logos come from official Fivetran, dbt, and Google assets, with URLs saved in [logo sources](assets/logos/sources.txt).

**Transition:** Open the demo.

## Slide 18 — Let's ask some questions!

**Purpose:** Deliver the business experience promised at the beginning. The audience should see a natural question become a grounded investigation, then a follow-up that crosses numerical data and documentary evidence.

**What is on screen:** Only the large title “Let's ask some questions!” and a blue, underlined “link” label on a white rectangle pointing to the private agent URL configured locally as `F1_GEMINI_URL`.

### Proposed 18-minute demo

**Minutes 0–5: A numerical question with inspectable grounding.**

> For 2025, which drivers gained the most positions from the published qualifying grid to the final Grand Prix result? Show average gain, number of matched races, and unmatched entries. Explain how you joined qualifying to the race.

The slide’s short question is intentionally conversational. The fuller prompt resolves average versus total gain and requests coverage. Ask to see the SQL and one underlying race. The point is not to celebrate a confident leaderboard; it is to show that the result has an inspectable definition and calculation.

Starting-grid records use main Qualifying session keys, while results use Race session keys. The relationship goes through the meeting and driver identity. Joining those tables on the same session key would be wrong. The published qualifying grid is also not independently reconciled to every subsequent grid penalty. Call it what it is instead of implying a perfect reconstruction of starting positions.

**Minutes 5–9: Follow the result.**

> Compare the top three drivers race by race. Which races explain the difference?

Use the resulting table or chart to select a real follow-up. Keep the interaction responsive to what appears. This is where the audience should feel the difference from a fixed dashboard: the next question does not have to be designed in advance.

**Minutes 9–14: Bring in attributed evidence.**

Choose a relevant 2025 event with press-conference coverage, then ask:

> What did the drivers say about their race? Find relevant press-conference passages and cite the sources. Distinguish their explanations from what the race data establishes.

Open a citation if practical. A quotation can support “the driver said X”; it does not, by itself, prove that X caused the measured result. If coverage is missing, acknowledge it and choose a covered event. Do not let the agent invent a transcript or infer a speaker-to-driver identity link that the data does not establish.

**Minutes 14–17: Explain a term or rule.**

> Explain the relevant racing term or rule in plain English, with a source. State which regulation edition you are using if the answer depends on a rule.

The useful behavior is combining explanation with provenance. A glossary definition and a regulation have different authority. Unknown effective dates remain unknown; current glossary text should not be presented as proof of historical law.

**Minutes 17–18: Connect back to business.**

“Replace drivers and races with customers and opportunities. Replace press conferences with customer conversations. This is the experience we want the data team to make possible.”

### Rehearsal and operational notes

This exact sequence is a proposed run of show, not a claim that every prompt has already been rehearsed successfully. Earlier browser verification exercised analytical and document questions, but the combined sequence should be rehearsed before the event.

- Confirm that the Gemini application opens under the presenting account. The recorded trial configuration expires on November 12, 2026; check access if presenting after that date.
- Keep cross-domain questions on 2025 because document coverage remains 2025.
- Confirm document embeddings and index readiness if data has recently changed. A completed dbt build is not enough; the [search status script](../scripts/inspect_document_search.py) reports asynchronous state.
- If metadata has changed, refresh the agent configuration after publishing it. The agent’s catalog context is a snapshot, while its data queries are live.
- Be ready to inspect SQL or discuss the relevant definition during query latency. Do not imply a canned result is live if a fallback is used.
- The managed agent uses caller permissions and a 10 GB per-query billed-bytes limit. Its read-only instruction is behavioral guidance, not an IAM restriction.

**Sources:** [Grid-to-finish query example](../agents/queries/grid_to_finish.sql), [transcript search example](../agents/queries/search_transcripts.sql), [transcript context example](../agents/queries/transcript_context.sql), [regulation search example](../agents/queries/search_regulations.sql), [glossary search example](../agents/queries/search_glossary.sql), [catalog](../agents/catalog.yml), [agent configuration](../scripts/configure_data_agent.py), and [current operational guidance](../AGENTS.md).

**What success looks like:** A useful answer, a transparent calculation, a meaningful follow-up, and evidence the audience can inspect. Honest handling of missing evidence strengthens the demonstration. The goal is not to assert that an agent never makes mistakes.

**Transition:** Return to the final slide after the conversation, rather than ending on the application UI.

## Slide 19 — Who has the fastest pit crew?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-01-pit-crews.jpg](gemini-01-pit-crews.jpg).

**Suggested narration:** Median stationary stop duration by team, with timing coverage and tail-delay discussion. Distinguish stationary service time from total pit-lane transit.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 20 — Who thrives in the rain?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-02-rain-performance.jpg](gemini-02-rain-performance.jpg).

**Suggested narration:** Average Grand Prix points per start in rain-observed versus dry races. Small-sample associations do not establish a causal rain-driving skill.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 21 — Who made the biggest comebacks?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-03-comeback-podiums.jpg](gemini-03-comeback-podiums.jpg).

**Suggested narration:** Published Qualifying grid position versus classified Race finish for podium results. Position gain differs from on-track overtakes and penalty-adjusted starting positions.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 22 — Which races are hardest to finish?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-04-hardest-to-finish.jpg](gemini-04-hardest-to-finish.jpg).

**Suggested narration:** DNF share among starters, excluding DNS. Retirements include mechanical failures and incidents, so this is not a measure of circuit hazard.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 23 — Which races finished closest?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-05-closest-finishes.jpg](gemini-05-closest-finishes.jpg).

**Suggested narration:** Smallest positive numeric winner-to-runner-up classified gaps. Read the chart as the agent’s recorded interpretation of the result data.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 24 — How did the title fight swing?

**What is on screen:** The complete presenter-supplied Gemini Enterprise screenshot, showing the pre-asked question, F1 Analyst response, and chart. Source: [gemini-06-title-fight.jpg](gemini-06-title-fight.jpg).

**Suggested narration:** Championship checkpoint snapshots for Norris, Piastri, and Verstappen. These are source snapshots rather than reconciled Race-only points.

**Claim boundary:** This is a recorded 2025 analysis response, not a live query. The screenshot’s answer and numerical results are preserved as supplied rather than independently reverified for this insertion.

## Slide 25 — Your data team should own your context

**Purpose:** Convert the demonstration into a leadership decision. The audience should leave with an owner and a practical starting point.

**What is on screen:** A large closing statement, “Your data team should own your context”, followed by “Use standard components: SQL database, skills, MCP”, “Keep your definitions and logic in code.”, and “Don't get trapped in a walled garden”.

**Suggested narration:** “Give your data team the mandate to make one valuable business conversation work. Make the underlying data and definitions reliable. Connect that context to a capable agent. Then expand from something useful.”

Owning context means retaining the ability to inspect, improve, and reuse the organization’s definitions and logic. It does not require building a foundation model, database, or every application component. This distinction is especially useful if someone interprets the talk as opposition to managed platforms: the demo itself uses several of them.

Use the remaining time for discussion. Useful questions to invite are which business conversation should come first, who owns the definitions, and how the team would evaluate answer quality. Avoid turning the close into another architecture lecture.

**Sources and limits:** This is the recommendation supported by the preceding examples and the demo. A thin context interface is sufficient for the analytical pattern shown; that does not prove it replaces every operational capability offered by proprietary platforms. Portability remains a property of the overall approach, with platform-specific implementation work where necessary.

**Final intended takeaway:** The data team already has many of the required skills and assets. Its next responsibility is to make company context useful to AI, and the company should retain ownership of that context.
