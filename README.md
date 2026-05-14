### System Verification & Validation (V-Model)

```mermaid
graph TD
    %% Sol Taraf: Verification (Aşağı İniş)
    A[Requirements Analysis: Corporate Credit Logic] --> B[System Design: Go Gateway + Python AI]
    B --> C[Architecture: Multi-Agent XAI]
    C --> D[Module Design: Defensive UI Bindings]
    D --> E((Implementation & Coding))

    %% Sağ Taraf: Validation (Yukarı Çıkış)
    E --> F[Unit Testing: Fallback UI / JSON Parsing]
    F --> G[Integration Testing: Go <-> Python Data Flow]
    G --> H[System Testing: Batch Processing & Caching]
    H --> I[Acceptance: Explainable Credit Decision]

    %% V-Model Çapraz Bağlantıları (Kesik Çizgiler)
    A -.->|Validation| I
    B -.->|Verification| H
    C -.->|Verification| G
    D -.->|Verification| F

    classDef default fill:#0f172a,stroke:#3b82f6,stroke-width:2px,color:#f8fafc;
    classDef implementation fill:#059669,stroke:#10b981,stroke-width:3px,color:#fff;
    class E implementation;