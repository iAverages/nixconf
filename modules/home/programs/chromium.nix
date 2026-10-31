{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.chromium;

  # Verified against chromium 155.0.8059.39 source (BASE_FEATURE names).
  # Unknown names are ignored by chrome, so this is safe across versions.
  disabledFeatures = [
    # Gemini in Chrome (side panel, toolbar button, context menu, auto browse)
    "Glic"
    "GlicRollout"
    "GlicTieredRollout"
    "GlicTieredRolloutV2"
    "GlicActor"
    "GlicContextMenu"
    "GlicTextSelectionContextMenu"
    "GlicSelectionPrompt"
    "GlicContextualCueBubble"
    "GlicTabGroups"
    "GlicPersonalContext"
    "PdfGlicSummarize"
    # "Chrome suggestions" Gemini nudges
    "ContextualCueing"
    "ContextualCueingV2"
    # AI Mode in omnibox / new tab page
    "AimEnabled"
    "Aim3pEntrypoint"
    "AiModeStartPack"
    "GoogleSearchAiModeWorkspace"
    # Server + on-device model execution backbone for all GenAI features
    "OptimizationGuideModelExecution"
    # Help me write
    "Compose"
    "ComposeNudge"
    "ComposeProactiveNudge"
    # AI history search
    "HistoryEmbeddings"
    "HistoryEmbeddingsAnswers"
    # Google Lens overlay
    "LensOverlay"
    "LensOverlayContextualSearchbox"
    "LensSearchAimM3"
    # Create themes with AI
    "CustomizeChromeWallpaperSearch"
    "CustomizeChromeWallpaperSearchButton"
    "NtpWallpaperSearchButton"
    # Autofill AI
    "AutofillAiWithDataSchema"
    # DevTools AI assistance
    "DevToolsConsoleInsights"
    "DevToolsFreestyler"
    "DevToolsGlobalAiButton"
    "DevToolsAiCodeCompletion"
    "DevToolsAiCodeGeneration"
    "DevToolsAiGeneratedTimelineLabels"
    "DevToolsAiAssistanceNetworkAgent"
    "DevToolsAiAssistancePerformanceAgent"
    "DevToolsAiAssistanceFileAgent"
    "DevToolsAiAssistanceAccessibilityAgent"
    "DevToolsAiAssistanceStorageAgent"
    "DevToolsAiAssistanceContextSelectionAgent"
  ];
in {
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      package = pkgs.google-chrome;
      commandLineArgs = [
        "--disable-features=${lib.concatStringsSep "," disabledFeatures}"
      ];
    };
  };
}
