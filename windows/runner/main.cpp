#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <cwchar>
#include <limits>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr int kDefaultWindowWidth = 1280;
constexpr int kDefaultWindowHeight = 720;
constexpr wchar_t kE2EWindowSizeEnv[] = L"MEMOX_E2E_WINDOW_SIZE";
constexpr DWORD kWindowSizeEnvBufferLength = 32;

bool ParsePositiveInt(const wchar_t* begin, const wchar_t* end, int* value) {
  if (begin == end) {
    return false;
  }

  int parsed = 0;
  for (const wchar_t* cursor = begin; cursor != end; ++cursor) {
    if (*cursor < L'0' || *cursor > L'9') {
      return false;
    }
    const int digit = *cursor - L'0';
    if (parsed > (std::numeric_limits<int>::max() - digit) / 10) {
      return false;
    }
    parsed = parsed * 10 + digit;
  }

  if (parsed <= 0) {
    return false;
  }

  *value = parsed;
  return true;
}

Win32Window::Size ResolveInitialWindowSize() {
  wchar_t env_value[kWindowSizeEnvBufferLength] = {};
  const DWORD length = GetEnvironmentVariableW(
      kE2EWindowSizeEnv, env_value, kWindowSizeEnvBufferLength);
  if (length == 0 || length >= kWindowSizeEnvBufferLength) {
    return Win32Window::Size(kDefaultWindowWidth, kDefaultWindowHeight);
  }

  const wchar_t* separator = std::wcschr(env_value, L'x');
  const wchar_t* fallback_separator = std::wcschr(env_value, L'X');
  if (separator == nullptr) {
    separator = fallback_separator;
  }
  if (separator == nullptr) {
    return Win32Window::Size(kDefaultWindowWidth, kDefaultWindowHeight);
  }

  int width = 0;
  int height = 0;
  if (!ParsePositiveInt(env_value, separator, &width) ||
      !ParsePositiveInt(separator + 1, env_value + length, &height)) {
    return Win32Window::Size(kDefaultWindowWidth, kDefaultWindowHeight);
  }

  return Win32Window::Size(width, height);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size = ResolveInitialWindowSize();
  if (!window.Create(L"memox", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
