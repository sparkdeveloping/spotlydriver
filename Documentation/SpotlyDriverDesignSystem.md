# SpotlyDriver Design System

SpotlyDriver uses the shared Spotly family contract with a cobalt driver identity and driver-specific operational density.

## Driver Cobalt Palette

Light:

- Accent: `#2563EB`
- Accent strong: `#1D4ED8`
- Accent soft: `#EAF1FF`
- Accent muted: `#F4F7FF`

Dark:

- Accent: `#60A5FA`
- Accent strong: `#93C5FD`
- Accent soft: `#172B4D`
- Accent muted: `#111F37`

The accent is used for selected native tabs, primary actions, links, location and zone emphasis, job selection emphasis, route/workflow progress, profile identity, and charts. Semantic success remains green; warning remains orange; error remains red.

## Shared Neutral Palette

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

## Typography

- Screen title: 34 bold
- Compact screen title: 28 bold
- Section title: 22 semibold
- Card title: 17 semibold
- Body: 16 regular
- Secondary body: 15 regular
- Caption: 13 regular
- Small status: 12 medium
- Metric large: 36 bold
- Metric standard: 30 bold
- Button: 16 semibold

System typography is used throughout and supports Dynamic Type.

## Spacing And Radius

- Root horizontal padding: 20
- Card padding: 16
- Section gap: 28
- Card gap: 12-16
- Button height: 52
- Compact button height: 44
- Row minimum height: 60
- Operational row minimum height: 64

Radii:

- Compact controls: 10-12
- Standard cards and section surfaces: 16
- Hero cards: 20
- Inputs: 14-16
- Pills: capsule

## Surfaces

Section surfaces use border, radius 16, no shadow, and internal dividers. Standard cards use border, radius 16, and restrained shadow. Elevated cards are reserved for metrics, active-job summaries, and high-priority job offers. Hero cards use radius 20 and restrained elevation.

## Navigation And Tabs

Root navigation uses native SwiftUI `TabView` with `Tab` values bound to `DriverAppState.selectedTab`. Jobs uses a native badge from pending dispatch requests. Pushed destinations hide the native tab bar and keep native inline titles and back swipe.

Home availability actions use the native `tabViewBottomAccessory` on iOS 26.1 and newer. Older OS versions use a scoped `safeAreaInset` fallback.

## Headers, Rows, And Controls

`SpotlyPageHeader` provides family root header geometry. `SpotlyListSection` and `SpotlyListRow` provide grouped profile/settings surfaces with 40-point icon containers, 60-point rows, full-width tap targets, one chevron, and internal dividers.

Buttons use cobalt for primary actions, cobalt-muted secondary styling, semantic red for destructive actions, and 44-point minimum targets. Jobs uses a native segmented picker for primary status filtering and shared chips for secondary filters.

## Statuses

`DriverStatusPill` and `VerificationStatusPill` use semantic colors with text labels:

- Online and completed: success green
- On delivery and pending review: information blue
- Paused and launch unavailable: warning orange
- Offline, rejected, failed, critical: red or neutral as appropriate

## Forms And Operational Flows

Forms use solid inputs, visible labels, radius 16, one-point borders, inline validation, keyboard-safe scrolling, and shared save/action bars. Operational flows use native inline navigation, section surfaces, standard/elevated cards, warning banners, shared timelines, and cobalt primary actions.

## Migrated Screens

- Entry, splash, welcome, sign in, onboarding
- Home
- Jobs
- Earnings
- Profile
- Notifications
- Job offer detail and summaries
- Active job
- Shopping, pickup code, customer PIN, cash collection, proof placeholder
- Completion summary
- Delivery zones
- Personal details, vehicle details, documents, payout method, availability preferences
- Performance, job history, shift history, incident history/detail
- Safety, help/support, report issue, terms, privacy, about, demo controls

## Remaining Screens

No remaining screen should use a separate visual system. New screens must use the shared family contract and cobalt Driver accent tokens.
