#include "screen_capturer_windows_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <atlimage.h>
#include <codecvt>
#include <fstream>
#include <map>
#include <memory>
#include <sstream>
#include <vector>

const double kBaseDpi = 96.0;

namespace screen_capturer_windows {

	HWND overlayWindow = NULL;
	POINT startPoint, endPoint;
	bool selecting = false;

	LRESULT CALLBACK OverlayProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
    std::cout << "start_captur_5" << std::endl;

		switch (message) {
			case WM_LBUTTONDOWN:
        std::cout << "start_captur_6" << std::endl;

				selecting = true;
				startPoint.x = LOWORD(lParam);
				startPoint.y = HIWORD(lParam);
				endPoint = startPoint;
				return 0;
			case WM_MOUSEMOVE:
				if (selecting) {
				endPoint.x = LOWORD(lParam);
				endPoint.y = HIWORD(lParam);
				InvalidateRect(hwnd, NULL, TRUE);
				}
				return 0;
			case WM_LBUTTONUP:
				selecting = false;
				DestroyWindow(hwnd);
				return 0;
			case WM_PAINT: {
				PAINTSTRUCT ps;
				HDC hdc = BeginPaint(hwnd, &ps);
				HBRUSH brush = CreateSolidBrush(RGB(0, 0, 0));
				RECT rect;
				GetClientRect(hwnd, &rect);
				FillRect(hdc, &rect, brush);
				SetROP2(hdc, R2_NOT);
				SelectObject(hdc, GetStockObject(NULL_BRUSH));
				Rectangle(hdc, startPoint.x, startPoint.y, endPoint.x, endPoint.y);
				DeleteObject(brush);
				EndPaint(hwnd, &ps);
				return 0;
			}
		}
		return DefWindowProc(hwnd, message, wParam, lParam);
	}

	RECT ShowSelectionOverlay() {

    std::cout << "start_captur_3" << std::endl;

		WNDCLASS wc = {};
		wc.lpfnWndProc = OverlayProc;
		wc.hInstance = GetModuleHandle(NULL);
		wc.lpszClassName = L"SelectionOverlay";
		RegisterClass(&wc);
	  
		overlayWindow = CreateWindowEx(WS_EX_TOPMOST | WS_EX_LAYERED, L"SelectionOverlay", NULL,
		WS_POPUP, 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN),
		NULL, NULL, GetModuleHandle(NULL), NULL);

		SetLayeredWindowAttributes(overlayWindow, 0, 128, LWA_ALPHA);
		ShowWindow(overlayWindow, SW_SHOW);
		UpdateWindow(overlayWindow);
		MSG msg;
		while (GetMessage(&msg, NULL, 0, 0)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
			if (!IsWindow(overlayWindow)) break;
		}
		RECT selectionRect = { min(startPoint.x, endPoint.x), min(startPoint.y, endPoint.y), 
		max(startPoint.x, endPoint.x), max(startPoint.y, endPoint.y) };

    std::cout << "start_captur_4" << std::endl;

		return selectionRect;
	}
	  

	void ScreenCapturerWindowsPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
		auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
		registrar->messenger(), "dev.leanflutter.plugins/screen_capturer",
		&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<ScreenCapturerWindowsPlugin>();
		channel->SetMethodCallHandler(
		[plugin_pointer = plugin.get()](const auto& call, auto result) {
			plugin_pointer->HandleMethodCall(call, std::move(result));
		});

		registrar->AddPlugin(std::move(plugin));
	}

	ScreenCapturerWindowsPlugin::ScreenCapturerWindowsPlugin() {}

	ScreenCapturerWindowsPlugin::~ScreenCapturerWindowsPlugin() {}

	void ScreenCapturerWindowsPlugin::CaptureScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call, 
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    std::cout << "start_captur_1" << std::endl;
    RECT selection = ShowSelectionOverlay();
    //HWND hwnd = GetDesktopWindow();

		HDC hdcScreen = GetDC(NULL);
		HDC hdcMemDC = CreateCompatibleDC(hdcScreen);
		HBITMAP hbitmap = CreateCompatibleBitmap(hdcScreen, selection.right - selection.left, selection.bottom - selection.top);
		SelectObject(hdcMemDC, hbitmap);
		BitBlt(hdcMemDC, 0, 0, selection.right - selection.left, selection.bottom - selection.top, hdcScreen, selection.left, selection.top, SRCCOPY);
		OpenClipboard(NULL);
		EmptyClipboard();
		SetClipboardData(CF_BITMAP, hbitmap);
		CloseClipboard();
		DeleteObject(hbitmap);
		DeleteDC(hdcMemDC);
		ReleaseDC(NULL, hdcScreen);

    std::cout << "start_captur_2" << std::endl;

		result->Success();
	}

	void ScreenCapturerWindowsPlugin::ReadImageFromClipboard(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		HBITMAP hbitmap = NULL;

		OpenClipboard(nullptr);
		hbitmap = (HBITMAP)GetClipboardData(CF_BITMAP);
		CloseClipboard();

		if (hbitmap == NULL) {
			result->Success();
			return;
		}

		std::vector<BYTE> pngBuf = Hbitmap2PNG(hbitmap);
		result->Success(flutter::EncodableValue(pngBuf));
		pngBuf.clear();
	}

	void ScreenCapturerWindowsPlugin::SaveClipboardImageAsPngFile(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		const flutter::EncodableMap& args =
				std::get<flutter::EncodableMap>(*method_call.arguments());

		std::string image_path =
				std::get<std::string>(args.at(flutter::EncodableValue("imagePath")));

		flutter::EncodableMap result_map = flutter::EncodableMap();
		HBITMAP hbitmap = NULL;

		OpenClipboard(nullptr);
		hbitmap = (HBITMAP)GetClipboardData(CF_BITMAP);
		CloseClipboard();

		bool saved = SaveHbitmapToPngFile(hbitmap, image_path);

		if (saved) {
			result_map[flutter::EncodableValue("imagePath")] =
					flutter::EncodableValue(image_path.c_str());
		}

		result->Success(flutter::EncodableValue(result_map));
	}

	std::vector<BYTE> ScreenCapturerWindowsPlugin::Hbitmap2PNG(HBITMAP hbitmap) {
		std::vector<BYTE> buf;
		if (hbitmap != NULL) {
			IStream* stream = NULL;
			CreateStreamOnHGlobal(0, TRUE, &stream);
			CImage image;
			ULARGE_INTEGER liSize;

			// screenshot to png and save to stream
			image.Attach(hbitmap);
			image.Save(stream, Gdiplus::ImageFormatPNG);
			IStream_Size(stream, &liSize);
			DWORD len = liSize.LowPart;
			IStream_Reset(stream);
			buf.resize(len);
			IStream_Read(stream, &buf[0], len);
			stream->Release();
		}
		return buf;
	}

	bool ScreenCapturerWindowsPlugin::SaveHbitmapToPngFile(HBITMAP hbitmap, std::string image_path) {
		if (hbitmap != NULL) {
			std::vector<BYTE> buf;
			IStream* stream = NULL;
			CreateStreamOnHGlobal(0, TRUE, &stream);
			CImage image;
			ULARGE_INTEGER liSize;

			// screenshot to png and save to stream
			image.Attach(hbitmap);
			image.Save(stream, Gdiplus::ImageFormatPNG);
			IStream_Size(stream, &liSize);
			DWORD len = liSize.LowPart;
			IStream_Reset(stream);
			buf.resize(len);
			IStream_Read(stream, &buf[0], len);
			stream->Release();

			// put the imapge in the file
			std::fstream fi;
			fi.open(image_path, std::fstream::binary | std::fstream::out);
			fi.write(reinterpret_cast<const char*>(&buf[0]), buf.size() * sizeof(BYTE));
			fi.close();

			return true;
		}
		return false;
	}

	void ScreenCapturerWindowsPlugin::HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		std::string method_name = method_call.method_name();

		if (method_name.compare("captureScreen") == 0) {
			CaptureScreen(method_call, std::move(result));
		} else if (method_name.compare("readImageFromClipboard") == 0) {
			ReadImageFromClipboard(method_call, std::move(result));
		} else if (method_name.compare("saveClipboardImageAsPngFile") == 0) {
			SaveClipboardImageAsPngFile(method_call, std::move(result));
		} else {
			result->NotImplemented();
		}
	}

} 
