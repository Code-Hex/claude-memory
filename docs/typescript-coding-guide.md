# TypeScript-Specific Practices

## 1. Leveraging Type System for Enhanced Safety

### State Management with Literal Types
```typescript
type OrderStatus = "draft" | "paid" | "shipped" | "cancelled";

function updateStatus(current: OrderStatus, next: OrderStatus): void {
  // Invalid transitions result in compile errors
}
```

### Utility Types for Intent Clarification
```typescript
// Read-only type
type ImmutableUser = Readonly<{
  id: string;
  name: string;
}>;

// Type for partial updates
type UserUpdate = Partial<ImmutableUser>;
```

## 2. Type-Driven Development (TDD)

### Brand Types for Domain Constraints
```typescript
type Email = string & { readonly __brand: "Email" };

function createEmail(value: string): Email | null {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) 
    ? value as Email 
    : null;
}
```

### Conditional Types for Dynamic Type Definitions
```typescript
type ApiResponse<T> = 
  T extends Array<any> ? PaginatedResponse<T> 
  : T extends object ? SingleResponse<T>
  : never;
```

## 3. TypeScript Testing Practices with Vitest

### Type-Safe Mock Definitions
```typescript
import { vi } from 'vitest';

const mockLogger = {
  log: vi.fn(),
  error: vi.fn()
} satisfies Logger;

test("should log payment failure", () => {
  const processor = new PaymentProcessor(mockLogger);
  processor.processPayment(-10);
  expect(mockLogger.error).toHaveBeenCalledWith("Invalid amount");
});
```

### Type Checking Tests
```typescript
test("should reject invalid status transition", () => {
  // @ts-expect-error - intentionally testing type error
  updateStatus("cancelled", "draft");
});
```

### Vitest-Specific Mock Utilities
```typescript
import { vi, beforeEach } from 'vitest';

// Mock entire modules
vi.mock('./database', () => ({
  saveUser: vi.fn(),
  getUser: vi.fn()
}));

// Spy on object methods
const userService = {
  createUser: vi.fn()
};

beforeEach(() => {
  vi.clearAllMocks();
});
```

## 4. TypeScript-Specific Readability Techniques

### Type Aliases for Complex Type Simplification
```typescript
type UserOrderHistory = {
  user: {
    id: string;
    name: string;
  };
  orders: Array<{
    id: string;
    date: Date;
    items: Array<{
      productId: string;
      quantity: number;
    }>;
  }>;
};
```

### Discriminated Unions for Type-Safe Branching
```typescript
type Result<T> = 
  | { type: "success"; value: T }
  | { type: "error"; message: string };

function handleResult(result: Result<number>): void {
  if (result.type === "success") {
    console.log(result.value * 2);
  } else {
    console.error(result.message);
  }
}
```

## 5. Collaboration Between Types and Tests

### Type-Guaranteed Test Coverage
```typescript
function processStatus(status: OrderStatus): void {
  switch (status) {
    case "draft": /* ... */ break;
    case "paid": /* ... */ break;
    case "shipped": /* ... */ break;
    case "cancelled": /* ... */ break;
    default:
      // Ensure exhaustive coverage with types
      const _exhaustiveCheck: never = status;
  }
}
```

### Test Data Construction with Utility Types
```typescript
import { beforeEach } from 'vitest';

// Create test data using Partial
const createTestUser = (overrides: Partial<User> = {}): User => ({
  id: "test-id",
  name: "Test User",
  email: "test@example.com",
  ...overrides
});

beforeEach(() => {
  const testUser = createTestUser({
    name: "Custom Test User"
  });
});
```

### Advanced Vitest Features for TypeScript
```typescript
import { describe, test, expect, vi } from 'vitest';

describe("PaymentProcessor", () => {
  test.concurrent("should handle multiple payments simultaneously", async () => {
    const processor = new PaymentProcessor(mockLogger);
    const payments = Array.from({ length: 10 }, (_, i) => 
      processor.processPayment(100 + i)
    );
    
    const results = await Promise.all(payments);
    expect(results).toHaveLength(10);
  });

  test.each([
    { amount: -10, expected: "Invalid amount" },
    { amount: 0, expected: "Amount must be positive" },
    { amount: 1000000, expected: "Amount exceeds limit" }
  ])("should validate amount: $amount", ({ amount, expected }) => {
    expect(() => processor.processPayment(amount))
      .toThrow(expected);
  });
});
```
