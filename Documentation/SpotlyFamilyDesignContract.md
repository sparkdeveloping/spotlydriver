# Spotly Family Design Contract

This contract defines the shared Customer, Business, and Driver visual family.

## Shared Palette

Light neutrals:

- Background: `#FFFFFF`
- Grouped background: `#F7F8FA`
- Secondary background: `#F3F4F6`
- Surface: `#FFFFFF`
- Text primary: `#111827`
- Text secondary: `#6B7280`
- Text tertiary: `#9CA3AF`
- Border: `#E5E7EB`
- Divider: `#E7E9E8`
- Disabled: `#C7CBD1`

Dark neutrals keep the same hierarchy with semantic dynamic colors, not a separate visual system.

## Type And Layout

- Screen title: 34 bold
- Compact title: 28 bold
- Section title: 22 semibold
- Card title: 17 semibold
- Body: 16 regular
- Secondary body: 15 regular
- Caption: 13 regular
- Small status: 12 medium
- Button: 16 semibold

Root horizontal padding is 20. Cards use 16 internal padding. Section gaps are 28. Rows are at least 60 high and all controls keep a 44-point minimum target.

## Surfaces

Section surfaces use radius 16, one-point border, no shadow, and internal dividers. Standard cards use radius 16, one-point border, and a 5 percent black shadow with radius 8 and y 2. Elevated cards use radius 16 and a 6 percent black shadow with radius 12 and y 4. Hero cards use radius 20 and restrained elevation.

## Navigation

Root navigation uses native `TabView`, native tab badges, outline tab symbols, and product accent tint. Pushed destinations use native inline navigation with the system back chevron and hide the root tab bar where appropriate.

## Controls

Search fields, segmented controls, chips, buttons, status pills, empty states, form fields, and list rows use shared neutral surfaces and product accent only for selection or action emphasis.

## Accessibility

All product apps support Dynamic Type, VoiceOver, Voice Control, Reduce Motion, semantic dark mode, 44-point targets, non-color status labels, and clear focus/tap areas.

## Driver Differences

SpotlyDriver uses cobalt as its brand accent, slightly denser operational job cards, larger primary operational actions, native tab bottom accessory for availability, safety emphasis, and workflow-specific status surfaces.
