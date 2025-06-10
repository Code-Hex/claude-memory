Of course. Here is the updated guide with a new, detailed section on best practices for moving beyond `@apply` in Tailwind CSS v4, based on the latest research and official recommendations. I have inserted it as the new section 4 and renumbered the subsequent sections.

***

# Tailwind CSS v4: Best Practices & Migration Guide

## Overview

Tailwind CSS v4 introduces significant improvements including the Oxide engine for dramatic performance gains, CSS-first configuration, native container queries, and composable variants. This guide covers essential best practices for maintainable code and smooth migration from v3.

**Note on Code Examples**: While this guide uses React for code examples due to its widespread adoption, all principles, patterns, and Tailwind utility classes apply universally across modern frameworks including Vue.js, Svelte, Angular, and others. The component-based architecture concepts translate directly to any framework's component system.

---

## Key Changes in v4

### Performance Improvements
- **Oxide Engine**: Up to 5x faster full builds, 100x+ faster incremental builds
- **Bundle Size**: 35% reduction (421KB to 271KB)
- **Build Times**: Tailwind website builds reduced from 960ms to 105ms

### Major Features
- **CSS-first Configuration**: Replace `tailwind.config.js` with `@theme` directive in CSS
- **Container Queries**: Native support without plugins
- **Composable Variants**: Complex conditional styling with `not-*` variants
- **Zero-Configuration**: Automatic content detection and unified toolchain

---

## Best Practices for Maintainable Code

### 1. Component-Based Architecture

#### Appropriate Component Granularity

The fundamental principle of breaking down complex UI into smaller, reusable components applies to all modern frontend frameworks. Whether you're using React's functional components, Vue's Single File Components, Svelte's component files, or Angular's component classes, the goal remains the same: encapsulate styling logic within meaningful component boundaries.

```jsx
// ❌ Bad: Long class lists in domain components
<div className="flex flex-col space-y-4 bg-white rounded-lg shadow-lg p-6 max-w-md mx-auto">
  <div className="flex items-center justify-between border-b border-gray-200 pb-4">
    <h2 className="text-xl font-semibold text-gray-800">User Profile</h2>
    <button className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md">
      Edit
    </button>
  </div>
</div>

// ✅ Good: Reusable UI components
const Card = ({ children, className = "" }) => (
  <div className={`bg-white rounded-lg shadow-lg p-6 ${className}`}>
    {children}
  </div>
);

const Button = ({ variant = "primary", children, ...props }) => (
  <button 
    className={buttonVariants({ variant })} 
    {...props}
  >
    {children}
  </button>
);
```

#### Using class-variance-authority (cva)
```typescript
// lib/tailwind-utils.ts - Framework agnostic utility
import { clsx, type ClassValue } from "clsx";

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

// lib/component-variants.ts - Button variants definition
import { cva, type VariantProps } from "class-variance-authority";

export const buttonVariants = cva(
  "font-semibold border rounded focus-visible:ring-2 focus-visible:ring-offset-2",
  {
    variants: {
      intent: {
        primary: "bg-blue-500 text-white border-transparent hover:bg-blue-600",
        secondary: "bg-white text-gray-800 border-gray-400 hover:bg-gray-100",
      },
      size: {
        small: "text-sm py-1 px-2",
        medium: "text-base py-2 px-4",
        large: "text-lg py-3 px-6",
      },
    },
    defaultVariants: {
      intent: "primary",
      size: "medium",
    },
  }
);

export type ButtonVariants = VariantProps<typeof buttonVariants>;

// React implementation
interface ButtonProps 
  extends React.ButtonHTMLAttributes<HTMLButtonElement>, 
         ButtonVariants {}

export const Button: React.FC<ButtonProps> = ({ 
  className, 
  intent, 
  size, 
  ...props 
}) => (
  <button 
    className={buttonVariants({ intent, size, className })} 
    {...props} 
  />
);

// Vue implementation (Composition API)
<script setup lang="ts">
import { buttonVariants, type ButtonVariants } from '@/lib/component-variants'
import { cn } from '@/lib/tailwind-utils'

interface Props extends ButtonVariants {
  class?: string
}

const props = withDefaults(defineProps<Props>(), {
  intent: 'primary',
  size: 'medium'
})
</script>

<template>
  <button 
    :class="buttonVariants({ 
      intent: props.intent, 
      size: props.size, 
      className: props.class 
    })"
  >
    <slot />
  </button>
</template>

// Svelte implementation
<script lang="ts">
  import { buttonVariants, type ButtonVariants } from '$lib/component-variants'
  
  interface $Props extends ButtonVariants {
    class?: string
  }
  
  export let intent: $Props['intent'] = 'primary'
  export let size: $Props['size'] = 'medium'
  export let className: $Props['class'] = ''
</script>

<button 
  class={buttonVariants({ intent, size, className })}
  on:click
  {...$restProps}
>
  <slot />
</button>
```

### 2. CSS-First Configuration & Theme Management

#### Leveraging @theme Directive
```css
/* styles/main.css */
@import "tailwindcss";

@theme {
  /* Custom colors */
  --color-brand-primary: oklch(0.84 0.18 117.33);
  --color-brand-secondary: oklch(0.70 0.15 200);
  
  /* Custom fonts */
  --font-sans: "Inter", "system-ui", sans-serif;
  --font-heading: "Poppins", sans-serif;
  
  /* Custom spacing */
  --spacing-18: 4.5rem;
  --spacing-72: 18rem;
  
  /* Custom breakpoints */
  --breakpoint-xs: 475px;
  --breakpoint-3xl: 1600px;
}

/* Multi-theme support */
@layer base {
  [data-theme='dark'] {
    --color-brand-primary: oklch(0.70 0.15 240);
    --color-text-primary: oklch(0.95 0.02 180);
  }
  
  [data-theme='ocean'] {
    --color-brand-primary: #aab9ff;
    --color-brand-secondary: #56d0a0;
  }
}
```

### 3. Container Queries for Component-Based Responsiveness

Container queries represent a paradigm shift in responsive design that benefits all component-based frameworks equally. The key insight is that components should respond to their immediate container context rather than the global viewport, making them truly portable and reusable across different layout contexts.

```html
<div class="@container resize-x overflow-auto border border-dashed p-4">
  <div class="grid grid-cols-1 @sm:grid-cols-2 @lg:grid-cols-3 @xl:grid-cols-4 gap-4">
    <div class="bg-blue-500 text-white p-4 rounded @sm:p-6">
      <h3 class="text-lg @lg:text-xl font-semibold">Product Card</h3>
      <p class="text-sm @lg:text-base mt-2 @sm:block hidden">
        Description that appears based on container size
      </p>
    </div>
  </div>
</div>
```

#### Combining Breakpoints and Container Queries

The strategy of using breakpoints for page-level layout decisions and container queries for component-internal responsiveness is a universal pattern. This separation of concerns works regardless of whether you're building with React's component tree, Vue's component hierarchy, or any other framework's component system.

```jsx
// Use breakpoints for page layout
// Use container queries for component internals
const ProductGrid = () => (
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    {products.map(product => (
      <ProductCard key={product.id} {...product} />
    ))}
  </div>
);

const ProductCard = ({ title, description, image }) => (
  <div className="@container bg-white rounded-lg shadow-md overflow-hidden">
    <img 
      src={image} 
      className="w-full @sm:h-48 @lg:h-56 object-cover" 
      alt={title}
    />
    <div className="p-4 @sm:p-6">
      <h3 className="text-lg @lg:text-xl font-semibold">{title}</h3>
      <p className="text-gray-600 @sm:mt-2 @sm:block hidden">
        {description}
      </p>
    </div>
  </div>
);
```

### 4. Rethinking Abstraction: Moving Beyond @apply

In previous versions of Tailwind, `@apply` was widely used to group utility classes into custom CSS classes like `.btn`. In v4, the core philosophy has shifted: **abstraction should primarily live in your components and templates, not your CSS.** This approach keeps styling co-located with markup, improving maintainability and leveraging the full power of the utility-first workflow.

The behavior of `@apply` has also changed due to the new engine. It can no longer see classes defined in other `@layer` blocks, making it unsuited for its previous role.

#### The Best Practice: Component-First Styling

Instead of creating a CSS class, create a reusable component. This is the most idiomatic and powerful pattern in v4.

**1. Using `cva` for Variants (as shown in section 1)**: This remains the gold standard for creating components with multiple variants (e.g., intent, size).

**2. Styling States with `data-*` Attributes**: For interactive states (`hover`, `focus`, `active`, etc.), the modern approach is to use `data-*` attributes provided by UI libraries like Headless UI and Radix UI, and style them directly in your template with Tailwind's `data-*` variants. This completely replaces the need for `@apply` for state-based styling.

```jsx
// ❌ Old way: Using @apply for states
/* styles.css */
.btn-primary {
  @apply px-4 py-2 font-semibold text-white bg-blue-600 rounded-md;
}
.btn-primary:hover {
  @apply bg-blue-700;
}

// ✅ New way: Styling states directly in the template
import { Button } from '@headlessui/react'

function StyledButton() {
  return (
    <Button className="
      /* Base Styles */
      px-4 py-2 font-semibold text-white bg-blue-600 rounded-md shadow
      /* State Styles using data-* variants */
      data-[hover]:bg-blue-700
      data-[active]:bg-blue-800
      data-[focus]:outline-none data-[focus]:ring-2 data-[focus]:ring-blue-500 data-[focus]:ring-offset-2
    ">
      Save changes
    </Button>
  )
}
```
This pattern makes your component's styling self-contained, explicit, and easy to understand without switching between files.

#### Fallbacks and Alternatives for CSS

When you absolutely must write custom CSS, here are the recommended v4 approaches:

- **For Reusing Design Tokens**: Use native CSS variables, which are automatically available from your `@theme` config.

  ```css
  /* Instead of @apply bg-brand-primary, use the CSS variable */
  .custom-gradient-header {
    background-image: linear-gradient(to right, var(--color-brand-primary), var(--color-brand-secondary));
  }
  ```

- **The `@utility` Escape Hatch**: If you need to create a new, reusable utility that can be used with `@apply` (e.g., during a gradual migration), you must wrap it in the `@utility` directive. This should be considered a last resort, not a primary pattern.

  ```css
  /* Use @utility for migration or very specific cases */
  @utility button-reset {
    @apply appearance-none border-none bg-transparent p-0 m-0 cursor-pointer;
  }

  /* This can now be applied */
  .some-legacy-component button {
    @apply button-reset;
  }
  ```

### 5. Utility Class Management

#### Avoiding @apply Overuse
```css
/* ❌ Bad: Overusing @apply defeats utility-first benefits */
.custom-button {
  @apply bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2;
}

/* ✅ Good: Use @apply sparingly, prefer components */
.prose-custom {
  @apply prose prose-lg max-w-none;
}

/* Limited use cases for @apply */
.legacy-override {
  @apply !important bg-red-500; /* Only for third-party overrides */
}
```

#### Class Organization Strategy

Consistent class organization improves code readability regardless of your template syntax. Whether you're working with JSX attributes, Vue template classes, Svelte class directives, or Angular class bindings, the principle of grouping related utilities together enhances maintainability.

```jsx
// Use prettier-plugin-tailwindcss for automatic sorting
const Component = () => (
  <div className="
    /* Layout */
    flex flex-col
    /* Spacing */
    gap-4 p-6
    /* Typography */
    text-lg font-semibold
    /* Colors */
    bg-white text-gray-900
    /* Borders & Effects */
    rounded-lg shadow-lg
    /* Responsive */
    sm:flex-row sm:gap-6
    /* States */
    hover:shadow-xl focus-within:ring-2
  ">
    Content
  </div>
);
```

### 6. Accessibility Best Practices

#### Screen Reader Utilities
**These accessibility patterns work across all frameworks - the key is the proper HTML structure and Tailwind classes.**

```jsx
// Icon buttons with accessible labels
const IconButton = ({ icon: Icon, label, ...props }) => (
  <button {...props}>
    <span className="sr-only">{label}</span>
    <Icon className="h-5 w-5" />
  </button>
);

// Skip links
const SkipLink = () => (
  <a 
    href="#main-content" 
    className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 bg-blue-600 text-white px-4 py-2 rounded"
  >
    Skip to main content
  </a>
);

<template>
  <button v-bind="$attrs">
    <span class="sr-only">{{ label }}</span>
    <component :is="icon" class="h-5 w-5" />
  </button>
</template>

<button {...$restProps}>
  <span class="sr-only">{label}</span>
  <svelte:component this={icon} class="h-5 w-5" />
</button>

<button>
  <span class="sr-only">{{ label }}</span>
  <ng-content></ng-content>
</button>
```

#### Focus Management
**Focus management principles are universal - these Tailwind classes provide consistent behavior across all frameworks.**

```jsx
// Focus-visible for keyboard-only focus indicators
const FocusableCard = ({ children }) => (
  <div 
    tabIndex={0}
    className="
      p-6 rounded-lg border border-gray-200
      focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2
      focus-visible:outline-none
    "
  >
    {children}
  </div>
);

// Focus-within for form containers
const FormSection = ({ children, title }) => (
  <fieldset className="
    border border-gray-200 rounded-lg p-4
    focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500
  ">
    <legend className="px-2 text-sm font-medium text-gray-700">
      {title}
    </legend>
    {children}
  </fieldset>
);

<template>
  <fieldset class="
    border border-gray-200 rounded-lg p-4
    focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500
  ">
    <legend class="px-2 text-sm font-medium text-gray-700">
      {{ title }}
    </legend>
    <slot />
  </fieldset>
</template>

<fieldset class="
  border border-gray-200 rounded-lg p-4
  focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500
">
  <legend class="px-2 text-sm font-medium text-gray-700">
    Form Section
  </legend>
  </fieldset>
```

### 7. Code Quality & Consistency

#### ESLint Configuration
```json
// .eslintrc.json
{
  "extends": ["plugin:tailwindcss/recommended"],
  "plugins": ["tailwindcss"],
  "rules": {
    "tailwindcss/no-custom-classname": ["error", {
      "whitelist": ["custom-scrollbar", "prose-custom"]
    }],
    "tailwindcss/enforces-shorthand": "error",
    "tailwindcss/no-contradicting-classname": "error"
  }
}
```

#### Prettier Configuration
```json
// .prettierrc
{
  "plugins": ["prettier-plugin-tailwindcss"],
  "tailwindFunctions": ["clsx", "cva", "cn"]
}
```

---

## Migration from v3 to v4

### 1. Using the Official Upgrade Tool

```bash
# Prerequisites: Node.js 20+
# Create a new Git branch first
git checkout -b upgrade-tailwind-v4

# Run the upgrade tool
npx @tailwindcss/upgrade

# Review changes carefully
git diff

# Test thoroughly in browser
npm run dev
```

### 2. Major Breaking Changes

#### Utility Name Changes
| v3 Class | v4 Class | Note |
|----------|----------|------|
| `shadow-sm` | `shadow-xs` | Scale shifted |
| `shadow` | `shadow-sm` | |
| `blur-sm` | `blur-xs` | Same pattern |
| `blur` | `blur-sm` | |
| `rounded-sm` | `rounded-xs` | Same pattern |
| `rounded` | `rounded-sm` | |
| `text-opacity-50` | `text-black/50` | New format |
| `flex-grow` | `grow` | Simplified |
| `outline-none` | `outline-hidden` | A11y improvement |

#### Configuration Migration
```css
/* v3: @tailwind directives */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* v4: Single import */
@import "tailwindcss";

/* v3: JavaScript config */
// tailwind.config.js
module.exports = {
  theme: {
    colors: {
      primary: '#3b82f6'
    }
  }
}

/* v4: CSS-first config */
@theme {
  --color-primary: #3b82f6;
}

/* If you need to keep JS config */
@config "./tailwind.config.js";
```

#### Default Value Changes
```css
/* Ring width: 3px → 1px */
/* v3 equivalent: ring-3 */
.ring { @apply ring-1; }

/* Border color: gray-200 → currentColor */
/* Explicit color needed if gray was expected */
.border { @apply border-gray-200; }

/* Button cursor: pointer → default */
/* Add cursor-pointer explicitly if needed */
button { @apply cursor-pointer; }
```

### 3. Manual Adjustments Required

#### Browser Support
- **v4 Requirements**: Safari 16.4+, Chrome 111+, Firefox 128+
- **Legacy Support**: Continue using v3.4 if older browsers needed

#### Build Tool Updates
```javascript
// Vite configuration
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [tailwindcss()],
});

// CLI commands
// v3: npx tailwindcss -i input.css -o output.css
// v4: npx @tailwindcss/cli -i input.css -o output.css
```

#### PostCSS Dependencies
```json
// Many PostCSS plugins now unnecessary
// Remove from package.json:
{
  "devDependencies": {
    // "postcss-import": "^15.1.0",    // Now built-in
    // "autoprefixer": "^10.4.14"     // Now built-in
  }
}
```

### 4. Testing Strategy

1. **Visual Testing**: Check all components and pages for layout breaks
2. **Functionality Testing**: Verify interactive elements work correctly
3. **Responsive Testing**: Test breakpoints and container queries
4. **Accessibility Testing**: Ensure focus indicators and screen reader support
5. **Performance Testing**: Verify build times and bundle sizes

---

## Development Workflow & Tooling

### VS Code Setup
```json
// settings.json
{
  "editor.quickSuggestions": {
    "strings": "on"
  },
  "tailwindCSS.experimental.configFile": "./src/styles/main.css",
  "tailwindCSS.experimental.tsserver": true
}
```

### Recommended Libraries
- **Component Variants**: `class-variance-authority`
- **Conditional Classes**: `clsx` or custom class name utilities
- **UI Libraries**: shadcn/ui, Headless UI, Radix UI (React), Nuxt UI (Vue), Skeleton (Svelte)
- **Icons**: Lucide React/Vue/Svelte, Heroicons, Tabler Icons

### Project Structure
```
src/
├── styles/
│   └── main.css              # @import "tailwindcss" + @theme
├── components/
│   ├── ui/                   # Reusable UI components
│   │   ├── button.tsx/.vue/.svelte
│   │   └── card.tsx/.vue/.svelte
│   └── features/             # Feature-specific components
├── lib/
│   ├── utils.ts              # Class name utilities (cn), etc.
│   └── variants.ts           # CVA variant definitions
└── pages/
```

---

## Conclusion

Tailwind CSS v4 represents a significant evolution in utility-first CSS frameworks. By following these best practices:

- **Embrace component-based architecture** for better maintainability
- **Leverage CSS-first configuration** for simpler theme management
- **Utilize container queries** for truly responsive components
- **Prioritize accessibility** in all implementations
- **Maintain code quality** with proper tooling and naming conventions

Teams can build scalable, maintainable, and performant applications while taking full advantage of v4's powerful new features.

**Universal Applicability**: The principles outlined in this guide transcend specific framework boundaries. While React is used for code examples, the core concepts apply equally to:

- **Vue.js**: Component composition, reactive data binding, and template-based rendering
- **Svelte**: Compile-time optimizations, component stores, and reactive assignments  
- **Astro**: Islands architecture, component hydration, and multi-framework support
- **Solid.js**: Fine-grained reactivity and JSX-based templates
- **Any component-based framework**: The utility-first methodology and architectural patterns remain consistent

The migration from v3, while requiring careful attention to breaking changes, opens the door to an improved development experience, better performance, and more flexible styling capabilities across any modern web development stack.