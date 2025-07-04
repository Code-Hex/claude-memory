Always question your own thoughts. If something is unclear or uncertain, don’t sit on it—use `WebSearch` tool to search the web immediately.

You must follow these guidelines at all times. No exceptions.
Clean code, testability, and performance are not optional — they are requirements.

## **1. Comments**

- Explain ***why***, not what — describe the intent or reasoning, not obvious behavior
- Clearly document **edge cases**, error conditions, or special assumptions
- Provide **context in TODOs** — explain what's missing and why it's important
- **Avoid unnecessary comments** — strive to write code that is self-explanatory
- **Prefer expressive code** (clear naming, clean structure) over relying on comments
- **Do not use emojis** in comments or documentation

## **2. Testability**

- Use **dependency inversion** — inject abstractions/interfaces, not concrete classes
- **Separate business logic** from I/O (e.g., API calls, DB access)
- Apply the **Single Responsibility Principle** — one function/module = one purpose

## **3. Code Readability**

- Use **early returns** to minimize nesting and reduce cognitive load
- Replace **magic numbers** with named constants for clarity and maintainability
- Write **positive conditionals** (`if isValid`) rather than double negatives (`if !isNotValid`)

## **4. Test Design**

- Write **descriptive test names** that express behavior in natural language
- Cover **boundary values**: min, max, and edge conditions

## **5. Performance Optimization Principles**

- Always **measure before optimizing** — establish baselines (e.g., Core Web Vitals)
- Use the **80/20 rule** to focus on high-impact bottlenecks
- **Iterate and validate** — measure impact after each change

## **6. Frontend Optimization**

- Use **modern image formats** (AVIF, WebP), responsive images, and lazy loading
- Preload fonts and use `font-display: swap` for fast rendering
- Apply **code splitting**, lazy loading, and remove unused CSS/JS
- Inline **critical CSS** to improve initial render speed

# Additional Coding Guides

- CSS Animation Guidelines: @docs/css-animation-coding-guide.md
- Tailwind CSS Best Practices: @docs/tailwind-css-guide.md  
- TypeScript Coding Standards: @docs/typescript-coding-guide.md

**BEFORE implementing ANY third-party service, you MUST use Context7 MCP:**

1. First use `mcp__context7__resolve-library-id` to find the library
2. Then use `mcp__context7__get-library-docs` with relevant topics
3. This ensures you get the latest, accurate documentation instead of relying on training data

If not found, switch to WebSearch tool.
