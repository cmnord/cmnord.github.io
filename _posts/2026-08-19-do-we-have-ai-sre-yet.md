---
layout: post
title: "Do we have AI SRE yet?"
date: 2026-08-19
published: false
description: "I miss being an SRE in the Old Days. Here's how we do release management with agents now"
tags: []
---

I never thought I'd say this, but I miss being an SRE in the Old Days:tm:[^pre-ai].

No matter how much code agents write for me today, I'm still the [directly
responsible individual][dri] for every bug. So when things go
wrong, I still have to crack open my laptop[^chicken-farm].

But unlike the old days, I don't know every line of code! I'm more like a manager
on call -- _yikes_.

## On call with AI: slower, more stressful

1. Get paged in Slack
1. Ack the page
1. Immediately copy+paste the page into my coding agent with "omg what is happening!!"
1. Agonize as it methodically investigates the issue
1. Steer random context into the chat as it goes

![A chat with a coding agent: the user says "omg our site is down please figure out what's happening!!" and the agent starts methodically investigating, listing repo contents and grepping for the production URL]({{ site.github.url }}/assets/img/agent-outage.png)
_make no mistakes_
{: .caption}

Generally with enough tokens and time the agents resolve the outage, but:

- **Outage comms are worse.**
I'm just pasting random hypotheses from my agent into the Slack thread.
I don't have as good of a sense of the ETA to resolution.

- **The agent doesn't work in outage mode by default.**
The default coding agent behavior is to investigate, then make a speculative
forward fix.
That's the wrong approach during an outage!
We should [mitigate first][generic-mitigations] with the lowest-risk change -- roll back! turn off the flag! --
rather than shipping _more_ new code with less testing.

![A timeline diagram of two responses to an outage: applying a generic mitigation halts user impact early, while investigating first lets the damage continue until the perfect fix ships. A cartoon volcanic island decorates each timeline, and its islander is much happier in the mitigate-early one][generic-mitigations-img]

_Source: [Generic Mitigations][generic-mitigations] by Jennifer Mace, O'Reilly Radar_
{: .caption}

After a few sweaty incidents, we've changed how we build to make being on call easier
with agents.

## Feature flag everything

The simplest tip I got from [Alon][alon] to ship faster was to feature flag
everything and test in prod.
When starting a new project I build feature flag support right away.
This was mostly a mindset change to remember to prompt "and put this behind a flag".

Beyond that, a line in `AGENTS.md` like "we use PostHog for feature flags" and a file
called `features.ts` are enough.

We don't ask the agents to decide what to feature flag themselves yet.
Do you?
Should we?

## Write a doc/skill explaining how you do release management

We built the [Napkin Math][napkin-math] iOS and Android apps in the YC Spring
2026 batch using [Expo][expo] with React Native.

Expo's magic trick is the "over-the-air update" -- a React Native app is built
with a native layer and an update layer of JavaScript and assets that can be
updated over-the-air (OTA) without the user needing to visit the App Store.

![Expo update layers][eas-layers-img]

_Source: [How EAS Update works][how-eas-works], Expo Docs_
{: .caption}

OTAs can be super useful to mitigate an outage if done right!

<details markdown="1">
<summary>More on how we did Expo updates</summary>

We generally followed [Expo OTA best practices][expo-ota].

We used the Expo [`appVersion`][eas-appversion] policy with the [release branch][release-branch] pattern from trunk-based development.
There's one Git branch per runtime version.

Suppose `main` targets runtime version `1.0.17` and a PR lands a breaking native change:

- The PR with the breaking native change bumps the app version to `1.0.18`.
- Right before merging, we branch `1.0.17-ota` off of `main` and push a final OTA to `1.0.17` users.
- Merge the PR. After the merge, updates published from `main` target `1.0.18`.
- If there's a JavaScript bug introduced in `1.0.17` we need to mitigate for users on both versions, we fix it on `main`, cherry-pick it onto `1.0.17-ota`, and then push OTAs from both branches.
</details>

After I explained this release management system to agents mid-outage a few times, it was helpful to just
write a doc into the repo.
I'd recommend you do the same!
Everyone's release process is a different special snowflake, so it's probably not just [In The Weights][chiang-newyorker].

### Recursive self-improvement: postmortems and runbooks

I confess: we haven't done this one yet!
Have you?

A few times now we've "fixed" a bug, only to have it crop up again.
The agents fixed some narrower version of the issue or didn't test the right
thing before declaring victory.

In a repeat outage it's stressful to watch the agent plod down the same investigation/discovery path, wasting tokens and time.
I don't want them to root-cause the same issue twice!

I'm thinking of adding a simple [recursive self-improvement][rsi] loop for the repo where we have:

```text
docs
├── postmortems
│   └── 2026-08-18-cloud-sync-failed-....md
└── runbooks
    └── supabase.md
```

I'm not sure what threshold for notability I'd use to warrant a postmortem or runbook except "when I say so".
But I'd want these to be primarily [agent-readable][ar-vs-hr] (not explicitly designed to be
human-readable) docs.

## Is this cope?

How much _should_ we change how we build software to adapt to coding agents, and how much should we just wait for the next model release?

My thought is:

- if it's generically making the agent "code better", it's probably gonna be in the weights.
  This is why I'm resistant to writing a generic "on-call" skill which would basically be "follow the Google SRE book".
- if it's about how your specific team/company does things, might as well make it legible to agents by writing it down

I still hold tightly (too tightly?) to some aspects of software development.

Maybe someday soon AI will replace my SRE job and we'll delete all the docs and walk into the sunset building freely :)

## Related reading

I read these after writing this post.
We're thinking along similar lines!

- [Compound Engineering: How Every Codes With Agents][compound-engineering], Dan Shipper and Kieran Klaassen
- [Stop trying to review AI's code faster: bet on rollback instead][bet-on-rollback], Quentin Rousseau
- [AI demands more engineering discipline. Not less][ai-discipline], Charity Majors

[^pre-ai]: Pre-AI.
[^chicken-farm]: Or [chicken farm][conductor-farm] on my phone

[alon]: https://x.com/alonzuman
[ai-discipline]: https://charity.wtf/p/ai-demands-more-engineering-discipline
[ar-vs-hr]: https://x.com/jynniit/status/2089860109707125033
[bet-on-rollback]: https://rootly.com/blog/stop-trying-to-review-ais-code-faster-bet-on-rollbacks-instead
[chiang-newyorker]: https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web
[compound-engineering]: https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents
[conductor-farm]: https://conductor.farm
[dri]: https://fortune.com/article/how-apple-works-inside-the-worlds-biggest-startup/
[eas-appversion]: https://docs.expo.dev/eas-update/runtime-versions/#use-a-runtime-version-policy-that-automatically-updates-the-runtime-version-when-native-code-is-updated
[eas-layers-img]: https://docs.expo.dev/static/images/eas-update/layers.png
[expo]: https://expo.dev
[expo-ota]: https://expo.dev/blog/5-ota-update-best-practices-every-mobile-team-should-know
[generic-mitigations]: https://www.oreilly.com/content/generic-mitigations/
[generic-mitigations-img]: https://www.oreilly.com/content/wp-content/uploads/sites/2/2020/12/02-2048x1126.png
[how-eas-works]: https://docs.expo.dev/eas-update/how-it-works/
[napkin-math]: https://napkinmath.club
[release-branch]: https://trunkbaseddevelopment.com/branch-for-release/
[rsi]: https://www.lesswrong.com/posts/JBadX7rwdcRFzGuju/recursive-self-improvement
