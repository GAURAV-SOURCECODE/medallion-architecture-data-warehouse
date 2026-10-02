# Data Quality Strategy

Data quality is validated after Silver and Gold loads.

## Silver checks

### Customer
- Null/duplicate `cst_id`
- Leading/trailing spaces
- Marital/gender standardization

### Product
- Null/duplicate `prd_id`
- Negative or missing cost
- Invalid product date windows

### Sales
- Invalid dates
- Order date after shipping/due date
- Null/non-positive measures
- `sales_amount = quantity × price`

### ERP
- Future birthdates
- Country normalization
- Category whitespace
- Maintenance normalization

## Gold checks

- Surrogate-key uniqueness
- Business-key uniqueness
- Fact-to-dimension integrity
- Sales calculation consistency
- Date ordering

## Test Philosophy

A quality query should normally return **zero rows**.

If rows are returned, investigate the source or transformation logic before treating the load as production-ready.
