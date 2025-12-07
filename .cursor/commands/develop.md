# /develop Command

**Description:** Analyzes project documentation and outputs the implementation plan for the current development stage

## Action Sequence

### 1. Project Documentation Analysis
- Reading IMPLEMENTATION_TODO.md to determine current status
- Analysis of .docs/shop-implementation-plan.md to understand stages
- Determination of unfinished tasks and priorities

### 2. Determination of Current Development Stage
- Identification of active stage by version (v0.2.0 - Application Layer)
- Analysis of dependencies between tasks
- Determination of critical tasks for continuation

### 3. Formation of Implementation Plan
- Grouping tasks by priorities
- Determination of execution sequence
- Identification of blocking dependencies

### 4. Output Plan to Chat
- Display of current stage and version
- List of tasks with status indication
- Recommendations for next steps

## Output Format
```
🚀 Development Stage Implementation Plan:

### Current Stage: Application Layer Implementation (v0.2.0)

#### Priority 1: Core Purchase Use Cases
- [ ] PurchaseGamePassUseCase.luau
- [ ] PurchaseSoftCurrencyItemUseCase.luau
- [ ] ValidatePurchaseUseCase.luau
- [ ] CheckPurchaseLimitUseCase.luau

#### Priority 2: Catalog Management
- [ ] GetProductCatalogUseCase.luau
- [ ] Product category management

#### Priority 3: Gift System Integration
- [ ] SendGiftUseCase.luau
- [ ] ReceiveGiftUseCase.luau

**Next Step:** Implement purchase use cases in Application Layer
```
