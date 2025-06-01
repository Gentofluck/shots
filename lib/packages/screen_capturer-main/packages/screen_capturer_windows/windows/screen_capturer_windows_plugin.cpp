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
	bool needsRedraw = false;
	bool isScreening = false;
	HBITMAP frozenScreenBitmap = NULL;
    HWND frozenScreenWindow = NULL;
	
	std::vector<RECT> monitorRects;

	BOOL CALLBACK MonitorEnumProc(HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData) {
		monitorRects.push_back(*lprcMonitor);
		return TRUE;
	}

	// Функция для заморозки экрана
    void FreezeScreen() {
        // Получаем размеры всех мониторов
        monitorRects.clear();
        EnumDisplayMonitors(NULL, NULL, MonitorEnumProc, 0);
        
        // Определяем общие границы
        RECT combinedRect = {};
        for (const auto& monitorRect : monitorRects) {
            combinedRect.left = min(combinedRect.left, monitorRect.left);
            combinedRect.top = min(combinedRect.top, monitorRect.top);
            combinedRect.right = max(combinedRect.right, monitorRect.right);
            combinedRect.bottom = max(combinedRect.bottom, monitorRect.bottom);
        }
        
        // Создаем скриншот
        HDC hdcScreen = GetDC(NULL);
        HDC hdcMem = CreateCompatibleDC(hdcScreen);
        frozenScreenBitmap = CreateCompatibleBitmap(hdcScreen, 
            combinedRect.right - combinedRect.left, 
            combinedRect.bottom - combinedRect.top);
        
        SelectObject(hdcMem, frozenScreenBitmap);
        BitBlt(hdcMem, 0, 0, 
            combinedRect.right - combinedRect.left, 
            combinedRect.bottom - combinedRect.top, 
            hdcScreen, combinedRect.left, combinedRect.top, SRCCOPY);
        
        // Очищаем ресурсы
        DeleteDC(hdcMem);
        ReleaseDC(NULL, hdcScreen);
    }
    
    // Обработчик сообщений для окна замороженного экрана
    LRESULT CALLBACK FrozenScreenProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
        switch (message) {
            case WM_PAINT: {
                PAINTSTRUCT ps;
                HDC hdc = BeginPaint(hwnd, &ps);
                
                // Рисуем замороженный скриншот
                HDC hdcMem = CreateCompatibleDC(hdc);
                SelectObject(hdcMem, frozenScreenBitmap);
                
                RECT rect;
                GetClientRect(hwnd, &rect);
                BitBlt(hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY);
                
                DeleteDC(hdcMem);
                EndPaint(hwnd, &ps);
                return 0;
            }
            
            case WM_ERASEBKGND:
                return 1; // Предотвращаем мерцание
        }
        return DefWindowProc(hwnd, message, wParam, lParam);
    }


	LRESULT CALLBACK OverlayProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {      
		SetCursor(LoadCursor(NULL, IDC_CROSS));
	
		switch (message) {
			case WM_LBUTTONDOWN:
				selecting = true;
				startPoint.x = LOWORD(lParam);
				startPoint.y = HIWORD(lParam);
				endPoint = startPoint;
				return 0;
				
			case WM_KEYDOWN:
				if (wParam == VK_ESCAPE) {
					// ESC pressed - cancel selection
					selecting = false;
					startPoint.x = 0;
					startPoint.y = 0;
					endPoint.x = 0;
					endPoint.y = 0;
					DestroyWindow(hwnd);
				}
				return 0;
				
			case WM_MOUSEMOVE:
				if (selecting) {
					endPoint.x = LOWORD(lParam);
					endPoint.y = HIWORD(lParam);
	
					if (startPoint.x != endPoint.x || startPoint.y != endPoint.y) {
						needsRedraw = true;
					}
	
					if (needsRedraw) {
						InvalidateRect(hwnd, NULL, TRUE);
						needsRedraw = false;
					}
				}
				return 0;
				
			case WM_LBUTTONUP:
				selecting = false;
				DestroyWindow(hwnd);
				return 0;
				
			case WM_PAINT: {
				PAINTSTRUCT ps;
				HDC hdc = BeginPaint(hwnd, &ps);
			
				RECT rect;
				GetClientRect(hwnd, &rect);
				int width = rect.right - rect.left;
				int height = rect.bottom - rect.top;
			
				HDC hdcMem = CreateCompatibleDC(hdc);
				HBITMAP hBitmap = CreateCompatibleBitmap(hdc, width, height);
				HGDIOBJ oldBmp = SelectObject(hdcMem, hBitmap);
			
				HBRUSH fillBrush = CreateSolidBrush(RGB(0, 0, 0));
				RECT fillRect = {startPoint.x, startPoint.y, endPoint.x, endPoint.y};
				FillRect(hdcMem, &fillRect, fillBrush); 
			
				HPEN borderPen = CreatePen(PS_SOLID, 2, RGB(255, 255, 255));  
				SelectObject(hdcMem, borderPen);
			
				Rectangle(hdcMem, startPoint.x, startPoint.y, endPoint.x, endPoint.y);
			
				BitBlt(hdc, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);
			
				DeleteObject(fillBrush);
				DeleteObject(borderPen);
				SelectObject(hdcMem, oldBmp);
				DeleteDC(hdcMem);
				DeleteObject(hBitmap);
			
				EndPaint(hwnd, &ps);
				return 0;
			}
		}
		return DefWindowProc(hwnd, message, wParam, lParam);
	}

	RECT ShowSelectionOverlay() {
        // Создаем окно для замороженного экрана
		startPoint.x = startPoint.y = endPoint.x = endPoint.y = 0;
        WNDCLASS wcFrozen = {};
        wcFrozen.lpfnWndProc = FrozenScreenProc;
        wcFrozen.hInstance = GetModuleHandle(NULL);
        wcFrozen.lpszClassName = L"FrozenScreen";
        RegisterClass(&wcFrozen);
        
        RECT combinedRect = {};
        for (const auto& monitorRect : monitorRects) {
            combinedRect.left = min(combinedRect.left, monitorRect.left);
            combinedRect.top = min(combinedRect.top, monitorRect.top);
            combinedRect.right = max(combinedRect.right, monitorRect.right);
            combinedRect.bottom = max(combinedRect.bottom, monitorRect.bottom);
        }
        
        // Создаем прозрачное окно поверх всего экрана
        frozenScreenWindow = CreateWindowEx(
            WS_EX_TOPMOST | WS_EX_LAYERED | WS_EX_TRANSPARENT,
            L"FrozenScreen", NULL,
            WS_POPUP,
            combinedRect.left, combinedRect.top,
            combinedRect.right - combinedRect.left,
            combinedRect.bottom - combinedRect.top,
            NULL, NULL, GetModuleHandle(NULL), NULL);
        
        // Устанавливаем прозрачность (можно регулировать)
		SetLayeredWindowAttributes(frozenScreenWindow, 0, 255, LWA_ALPHA);

        ShowWindow(frozenScreenWindow, SW_SHOW);
        UpdateWindow(frozenScreenWindow);
        
        // Далее оригинальный код создания окна выбора области
        WNDCLASS wc = {};
        wc.lpfnWndProc = OverlayProc;
        wc.hInstance = GetModuleHandle(NULL);
        wc.lpszClassName = L"SelectionOverlay";
        RegisterClass(&wc);
        
        overlayWindow = CreateWindowEx(
            WS_EX_TOPMOST | WS_EX_LAYERED, 
            L"SelectionOverlay", NULL,
            WS_POPUP, 
            combinedRect.left, combinedRect.top,
            combinedRect.right - combinedRect.left, 
            combinedRect.bottom - combinedRect.top,
            NULL, NULL, GetModuleHandle(NULL), NULL);
        
        SetLayeredWindowAttributes(overlayWindow, 0, 64, LWA_ALPHA);
        SetFocus(overlayWindow);
        
        ShowWindow(overlayWindow, SW_SHOW);
        UpdateWindow(overlayWindow);
        
        // Обработка сообщений
        MSG msg;
        while (GetMessage(&msg, NULL, 0, 0)) {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
            if (!IsWindow(overlayWindow)) break;
        }
        
        // Очищаем ресурсы
        DestroyWindow(frozenScreenWindow);
        if (frozenScreenBitmap) {
            
			//DeleteObject(frozenScreenBitmap);
            //frozenScreenBitmap = NULL;
        }
        
        // Возвращаем выбранную область
        RECT selectionRect = { 
            min(startPoint.x, endPoint.x), 
            min(startPoint.y, endPoint.y),
            max(startPoint.x, endPoint.x), 
            max(startPoint.y, endPoint.y) 
        };
        
        return selectionRect;
    }

	// Зарегистрируем плагин
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
	
	// Функция для захвата скриншота с нескольких мониторов
	void CaptureMultipleMonitors(HDC hdcScreen, const std::vector<RECT>& monitors, HDC hdcMemDC, HBITMAP& hbitmap, std::vector<BYTE>& imgData) {
		// Определение границ рабочего пространства
		int minX = INT_MAX, minY = INT_MAX, maxX = INT_MIN, maxY = INT_MIN;
		for (const RECT& monitor : monitors) {
			minX = min(minX, monitor.left);
			minY = min(minY, monitor.top);
			maxX = max(maxX, monitor.right);
			maxY = max(maxY, monitor.bottom);
		}
	
		int totalWidth = maxX - minX;
		int totalHeight = maxY - minY;
		
		// Создаем совместимый битмап
		hbitmap = CreateCompatibleBitmap(hdcScreen, totalWidth, totalHeight);
		SelectObject(hdcMemDC, hbitmap);
	
		// Захватываем каждый монитор в его реальное положение
		for (const RECT& monitor : monitors) {
			int x = monitor.left - minX; // Смещение относительно общего начала координат
			int y = monitor.top - minY;
			int width = monitor.right - monitor.left;
			int height = monitor.bottom - monitor.top;
	
			BitBlt(hdcMemDC, x, y, width, height, hdcScreen, monitor.left, monitor.top, SRCCOPY);
		}
	
		// Сохранение в PNG
		CImage img;
		img.Attach(hbitmap);
		IStream* stream = NULL;
		CreateStreamOnHGlobal(NULL, TRUE, &stream);
		img.Save(stream, Gdiplus::ImageFormatPNG);
	
		ULARGE_INTEGER liSize;
		IStream_Size(stream, &liSize);
		DWORD len = liSize.LowPart;
		IStream_Reset(stream);
	
		imgData.resize(len);
		IStream_Read(stream, imgData.data(), len);
		stream->Release();
	}
	
	void ScreenCapturerWindowsPlugin::CaptureScreen(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		if (!isScreening) {
			isScreening = true;

			FreezeScreen();
			RECT selection = ShowSelectionOverlay();

			if (selection.left == selection.right || selection.top == selection.bottom) {
				isScreening = false;
				result->Success(); 
				return;
			}

			// Работаем с замороженным скриншотом
			HDC hdcScreen = GetDC(NULL);
			HDC hdcMemDC = CreateCompatibleDC(hdcScreen);
			SelectObject(hdcMemDC, frozenScreenBitmap);

			// Вырезаем нужную область из frozenScreenBitmap
			int width = selection.right - selection.left;
			int height = selection.bottom - selection.top;
			
			HDC hdcSelectionDC = CreateCompatibleDC(NULL);
			HBITMAP hbitmapSelection = CreateCompatibleBitmap(hdcScreen, width, height);
			SelectObject(hdcSelectionDC, hbitmapSelection);

			// Копируем выделенную область из frozenScreenBitmap
			BitBlt(hdcSelectionDC, 0, 0, width, height, 
				hdcMemDC, selection.left, selection.top, SRCCOPY);

			// Конвертация в PNG
			CImage img;
			img.Attach(hbitmapSelection);
			IStream* stream = NULL;
			CreateStreamOnHGlobal(NULL, TRUE, &stream);
			img.Save(stream, Gdiplus::ImageFormatPNG);

			// Получаем данные
			ULARGE_INTEGER liSize;
			IStream_Size(stream, &liSize);
			DWORD len = liSize.LowPart;
			IStream_Reset(stream);

			std::vector<BYTE> imgData(len);
			IStream_Read(stream, imgData.data(), len);
			stream->Release();

			// Возвращаем выделенную область
			result->Success(imgData);

			// Очистка ресурсов
			DeleteObject(hbitmapSelection);
			DeleteDC(hdcSelectionDC);
			DeleteDC(hdcMemDC);
			ReleaseDC(NULL, hdcScreen);
			
			if (frozenScreenBitmap) {
				DeleteObject(frozenScreenBitmap);
				frozenScreenBitmap = NULL;
			}
		}
		
		isScreening = false;
	}
		

	std::string ToBase64(const std::vector<BYTE>& input) {
		static const char* base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		std::string ret;
		int val = 0, valb = -6;
		for (unsigned char c : input) {
			val = (val << 8) + c;
			valb += 8;
			while (valb >= 0) {
				ret.push_back(base64_chars[(val >> valb) & 0x3F]);
				valb -= 6;
			}
		}
		if (valb > -6) ret.push_back(base64_chars[((val << 8) >> (valb + 8)) & 0x3F]);
		while (ret.size() % 4) ret.push_back('=');
		return ret;
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

			image.Attach(hbitmap);
			image.Save(stream, Gdiplus::ImageFormatPNG);
			IStream_Size(stream, &liSize);
			DWORD len = liSize.LowPart;
			IStream_Reset(stream);
			buf.resize(len);
			IStream_Read(stream, &buf[0], len);
			stream->Release();

			std::fstream fi;
			fi.open(image_path, std::fstream::binary | std::fstream::out);
			fi.write(reinterpret_cast<const char*>(&buf[0]), buf.size() * sizeof(BYTE));
			fi.close();

			return true;
		}
		return false;
	}

	void ScreenCapturerWindowsPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		std::string method_name = method_call.method_name();
	
		if (method_name.compare("captureScreen") == 0) {
		  CaptureScreen(method_call, std::move(result));
		} else {
		  result->NotImplemented();
		}
	}

} 


